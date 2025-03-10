%% set script
clearvars;
clc;
addpath(genpath(pwd));

%%%%%%%%%% DEFINE ANALYSIS %%%%%%%%%%vacc
%define mono or combination aa therapy
%therapy = "aa"; %combination therapy
%therapy = "a"; %mono therapy

%define whether there exists an fraction of vaccinated
%sub-population (default if yes, is 0.5)
vacc = 0; %no vaccinated sub-population
%vacc = 1;

parameterization = "Regoes";
% parameterization = "Stilianakis";R

%define whether to consider all infected or only symptomatic (detectable)
%individuals in analysis
% focus_ind = "all"; %all infected individuals
%focus_ind = "sympt"; %only symptomatic (detectable) individuals

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% define initial conditions

opts = spreadsheetImportOptions("NumVariables", 3);
opts.VariableNames = ["States", "DescriptionOfStates", "t0"];

%specify sheet and range
opts.Sheet = "InitialStates";
opts.DataRange = "A2:C29";

%import the data
states0 = readtable(".\Models_summary.xlsx",...
    opts, "UseExcel", false, "ReadVariableNames",true);

for i_states = 1:length(states0.States)
    eval(strcat(states0.States(i_states), "0", "=", states0.t0(i_states), ";"));
end

%% define model parameter and rate constants

opts = spreadsheetImportOptions("NumVariables", 14);

%specify sheet and range
opts.Sheet = "ParameterValues";
opts.DataRange = "A3:N139";

%specify column names and types
opts.VariableNames = ["Parameters", "ParameterDescriptionsComb", ...
    "ParameterDescriptionsMono", "Var4", "ParametersRel", "Var6", "Var7",...
    "Var8", "Var9", "Var10", "ValuesComb_Stilianakis",...
    "ValuesMono_Stilianakis", "ValuesComb_Regoes", "ValuesMono_Regoes"];
opts.SelectedVariableNames = ["Parameters", "ParameterDescriptionsComb",...
    "ParameterDescriptionsMono", "ParametersRel", "ValuesComb_Stilianakis",...
    "ValuesMono_Stilianakis","ValuesComb_Regoes", "ValuesMono_Regoes"];

%import the data
pars = readtable(".\Models_summary.xlsx",...
    opts, "UseExcel", false, "ReadVariableNames",true);

if strcmp(parameterization,"Regoes")
    pars.ValuesComb = pars.ValuesComb_Regoes;
    pars.ValuesMono = pars.ValuesMono_Regoes;
elseif strcmp(parameterization,"Stilianakis")
    pars.ValuesComb = pars.ValuesComb_Stilianakis;
    pars.ValuesMono = pars.ValuesMono_Stilianakis;
end


%% simulate the system

%define time span of analysis
tspan = 0:0.1:100;

%define linewidth for plots
LW = 1.5;

h1 = figure;
h2 = figure;
h3 = figure;
h4 = figure;
h5 = figure;
h6 = figure;
h7 = figure;
h8 = figure;

%specificy colors for other plots
cmap2 = [0, 0, 0; %black
    95,95,211; %blue
    100,211,141]./255; %green

cmap3 = [225, 225, 225;...
    180, 180, 180;...
    180, 180, 180;...
    211, 95, 95;...
    211, 95, 95;...
    211, 95, 95;...
    211, 95,95]./255;

i_count = 1;

for i_scenario = [1,2,3,2,3] %1 - no treatment, 2 - antiviral treatment, 3 - antiviral prophylaxis, 4 - antiviral treatment + prophylaxis

    for i_test = 1:11

        if i_count < 4
            i_rel_res_form = i_test-1;
            i_rel_trans_fit = 1;
        else
            i_rel_res_form = 1;
            i_rel_trans_fit = i_test-1;
        end

        for i_parrel = 1:length(pars.ParametersRel)
            if ~strcmp(pars.ParametersRel(i_parrel),"")
                eval(strcat(pars.ParametersRel(i_parrel), "=", pars.ValuesMono(i_parrel), ";"));
            end
        end

        for i_par = 1:length(pars.Parameters)
            if strcmp(pars.ParameterDescriptionsMono(i_par),"")
                eval(strcat(pars.Parameters(i_par), "=", pars.ValuesMono(i_par), ";"));
                eval(strcat("par_mono(i_par)", "=", pars.ValuesMono(i_par), ";"));
                if strcmp(pars.Parameters(i_par),"beta_S_I_r") || strcmp(pars.Parameters(i_par),"beta_S_I_r_s") %redefine beta_S_I_r or beta_S_I_r_s according to the tranmission fitness given by i_rel_trans_fit
                    eval(strcat(pars.Parameters(i_par), "=", "i_rel_trans_fit*", pars.ValuesMono(i_par), ";"));
                    eval(strcat("par_mono(i_par)", "=", "i_rel_trans_fit*", pars.ValuesMono(i_par), ";"));
                end
                if strcmp(pars.Parameters(i_par),"k_aa_r") %redefine k_aa_r to the resistance formation rate given by i_rel_res_form
                    eval(strcat(pars.Parameters(i_par), "=", "i_rel_res_form*", pars.ValuesMono(i_par), ";"));
                    eval(strcat("par_mono(i_par)", "=", "i_rel_res_form*", pars.ValuesMono(i_par), ";"));
                end
            elseif strcmp(pars.ParameterDescriptionsMono(i_par),"NaN")
                eval(strcat(pars.Parameters(i_par), "=", "0", ";"));
                eval(strcat("par_mono(i_par)", "=", "0", ";"));
            else
                eval(strcat(pars.Parameters(i_par), "=", pars.ParameterDescriptionsMono(i_par), ";"));
                eval(strcat("par_mono(i_par)", "=", pars.ParameterDescriptionsMono(i_par), ";"));
            end
        end


        %extract the initial values and re-structure in one vector y0
        y0 = [];
        for i_states = 1:length(states0.States)
            y0 = [y0; eval(strcat(states0.States(i_states), "0"), ";")];
        end

        if vacc == 0 %redefine initial value if no vaccination (vaccinated sub-population as suggested in script is redefined as non-vaccinated)
            y0(1) = S0+S_v0;
            y0(15) = 0;
        end

        options = odeset('NonNegative',1:length(y0)); %specify non-negative values for ODE solver
        [t1,y1] = ode45(@(t,y) odefcn_influenza_before_Theta_pr(t,y,par_mono),tspan,y0,options); %solve ODE

        %redefine the results from y1 to population names (for
        %understanding)
        for i_y = 1:size(y1,2)
            eval(strcat(states0.States(i_y), "=", "y1(:,i_y);"));
        end

        I_all_no = I+I_s+I_aa+I_s_aa+I_r+I_r_s+I_aa_r+I_s_aa_r+I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
            +I_v+I_v_s+I_v_aa+I_v_s_aa+I_v_r+I_v_r_s+I_v_aa_r+...
            I_v_s_aa_r+I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected individuals
        % Is_all_no = I_s+I_s_aa+I_r_s+I_s_aa_r+I_rr_s+I_s_aa_rr...
        %     +I_v_s+I_v_s_aa+I_v_r_s+I_v_s_aa_r+I_v_rr_s+I_v_s_aa_rr; %all infected individuals with clinical symptoms (detectable)

        %determine the time point at which the outbreak is identified as
        %epidemic and potential treatment options can be initiated (defined
        %by 5% of the population being infected with clincal symptoms)
        f_Total_I_s_all =  (delta_I_I_s*I + delta_I_v_I_v_s*I_v)/10; %calulate the number of infected individuals with clinical symptoms
        ind = find(cumsum(f_Total_I_s_all) > 0.05*(S0+S_v0+1),1,"first"); %find the time point at which this number exceeds 5% of the population

        if isempty(ind) == 0 %if this threshold is reached, set a potential initiation of treatment to that time point
            time_treat = t1(ind);
        else
            time_treat = max(tspan); %if this threshold is not reached, no treatment during time span of analysis
        end

        %introduce the treatment Theta_aa according to i_scenario
        if i_scenario == 1
            par_mono(133) = 0; %no treatment
            par_comb(133) = 0; %no treatment
        elseif i_scenario == 2
            par_mono(133) = 0.7; %antiviral treatment
            par_comb(133) = 0.7; %no treatment
        elseif i_scenario == 3
            par_mono(133) = 0; %only prophylaxis (introduced differently)
            par_comb(133) = 0; %no treatment
        else
            par_mono(133) = 0.7; %antiviral treatment (+ prophylaxis)
            par_comb(133) = 0.7; %no treatment
        end
        Theta_aa  = par_mono(133);

        %redefine initial states to time of treatment for second
        %evaluation of system with treatment (starting at
        %previously determined time_treat = ind)
        if i_scenario > 1 %only if treatment
            if isempty(ind) %if no detection of epidemic, no treatment, and hence no need to re-run system with treatment
            else
                y0_2 = y1(ind,:); %redefine initial state to state at treatment initiation
            end
        end

        %apply prophylaxis to all indiviudals not yet infected or
        %symptomatic (S -> S_aa, I -> I_aa, I_r -> I_aa_r, I_rr ->
        %I_aa_rr, and same for vaccinated subpopulation)
        if i_scenario > 2 && isempty(ind) == 0 %for connecting y to compartment name see odefcn_influenza_before_Theta_pr.m
            y0_2(1) = 0; %no S (all S_aa)
            y0_2(11) = y1(ind,1);
            y0_2(2) = 0; %no I (all I_aa)
            y0_2(12) = y1(ind,2);
            y0_2(3) = 0; %no I_s (all I_aa_s)
            y0_2(4) = y1(ind,3);

            % y0_2(5) = 0; %no I_r (all I_aa_r)
            % y0_2(13) = y1(ind,5);
            % y0_2(8) = 0; %no I_r (all I_aa_rr)
            % y0_2(14) = y1(ind,8);

            y0_2(15) = 0; %no S_v (all S_v_aa)
            y0_2(25) = y1(ind,15);
            y0_2(16) = 0; %no I_v (all I_v_aa)
            y0_2(26) = y1(ind,16);

            y0_2(17) = 0; %no I_v_s (all I_v_aa_s)
            y0_2(18) = y1(ind,17);

            % y0_2(19) = 0; %no I_v_r (all I_v_aa_r)
            % y0_2(27) = y1(ind,19);
            % y0_2(22) = 0; %no I_v_rr (all I_v_aa_rr)
            % y0_2(28) = y1(ind,22);
        end

        % if vacc == 1
        if i_scenario == 1 %no treatment - no rerun needed
            % %redefine initial state
            % if test_vacc == 0
            %     y0 = [];
            %     for i_states = 1:length(states0.States)
            %         y0 = [y0; eval(strcat(states0.States(i_states), "0"), ";")];
            %     end
            % end
            % tspan2 = 0:0.1:max(tspan);
            % [t2,y2] = ode45(@(t,y) odefcn_influenza_after_Theta_pr(t,y,par),tspan2,y0,options);
            y = y1;
            t = t1;
        else
            if isempty(ind) %if no detection of epidemic, no treatment, no need to rerun
                y = y1;
                t = t1;
            else
                tspan2 = 0:0.1:(max(tspan)-time_treat); %redefine time frame for evaluation (time left between treatment initiation and max(tspan))
                [t2,y2] = ode45(@(t,y) odefcn_influenza_after_Theta_pr(t,y,par_mono),tspan2,y0_2,options); %resolve ODE this time WITH treatment
                y = [y1(1:ind,:);y2(2:end,:)]; %summarize the dynamics before and after treatment
                t = [t1(1:ind);t2(2:end)+time_treat];

                %redefine the results from y1 to population names (for
                %understanding)
                for i_y = 1:size(y,2)
                    eval(strcat(states0.States(i_y), "=", "y(:,i_y);"));
                end
            end
        end

        %determine fdifferent subpopulaitons
        I_all(i_test,:) = I+I_s+I_aa+I_s_aa+I_r+I_r_s+I_aa_r+I_s_aa_r+I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
            +I_v+I_v_s+I_v_aa+I_v_s_aa+I_v_r+I_v_r_s+I_v_aa_r+...
            I_v_s_aa_r+I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected individuals
        Is_all(i_test,:) = I_s+I_s_aa+I_r_s+I_s_aa_r+I_rr_s+I_s_aa_rr...
            +I_v_s+I_v_s_aa+I_v_r_s+I_v_s_aa_r+I_v_rr_s+I_v_s_aa_rr; %all infected individuals with clinical symptoms (detectable)
        Ir_rr_all(i_test,:) = I_r+I_r_s+I_aa_r+I_s_aa_r+I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
            +I_v_r+I_v_r_s+I_v_aa_r+I_v_s_aa_r+I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
        Is_r_rr_all(i_test,:) = I_r_s+I_s_aa_r+I_rr_s+I_s_aa_rr...
            +I_v_r_s+I_v_s_aa_r+I_v_rr_s+I_v_s_aa_rr; %all infected individuals with clinical symptoms (detectable) shedding resistant virus (single or double resistant in case of combination therapy)
        Ir_all(i_test,:) = I_r+I_r_s+I_aa_r+I_s_aa_r...
            +I_v_r+I_v_r_s+I_v_aa_r+I_v_s_aa_r; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
        Is_r_all(i_test,:) = I_r_s+I_s_aa_r...
            +I_v_r_s+I_v_s_aa_r; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
        Irr_all(i_test,:) = I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
            +I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected individuals shedding double resistant virus (only relevant if combination therapy applied)
        Is_rr_all(i_test,:) = I_rr_s+I_s_aa_rr+I_v_rr_s+I_v_s_aa_rr; %all infected individuals shedding double resistant virus (only relevant if combination therapy applied)

        if i_test == 1
            if i_count > 1
                figure(eval(sprintf('h%d',i_count-1)))
            end
        end

        %for each population, define the total number of
        %indiviudals
        Total(:,1) = (beta_S_I*I + beta_S_I_s*I_s + beta_S_I_s_aa*I_s_aa + beta_S_I_aa*I_aa...
            + beta_S_I_v*I_v + beta_S_I_v_s*I_v_s + beta_S_I_v_s_aa*I_v_s_aa + beta_S_I_v_aa*I_v_aa).*S; %S_I
        Total(:,2) = delta_I_I_s*I; %I_I_s
        Total(:,3) = gamma_I*I; %I_o
        Total(:,4) = zeros(length(t),1); %I_I_aa
        Total(:,5) = [zeros(length(0:0.1:time_treat),1);Theta_aa*I_s((find(t==time_treat)+1):end)]; %I_s_I_s_aa
        Total(:,6) = gamma_I_s*I_s; %I_s_o
        Total(:,7) = gamma_I_s_aa*I_s_aa; %I_s_aa_o
        Total(:,8) = k_aa_r*q_s*I_s_aa; %I_s_aa_I_s_aa_r
        Total(:,9) = (beta_S_I_r*I_r + beta_S_I_r_s*I_r_s + beta_S_I_s_aa_r*I_s_aa_r + beta_S_I_aa_r*I_aa_r...
            + beta_S_I_v_r*I_v_r + beta_S_I_v_r_s*I_v_r_s + beta_S_I_v_s_aa_r*I_v_s_aa_r + beta_S_I_v_aa_r*I_v_aa_r).*S; %S_I_r
        Total(:,10) = delta_I_r_I_r_s*I_r; %I_r_I_r_s
        Total(:,11) = gamma_I_r*I_r; %I_r_o
        Total(:,12) = zeros(length(t),1); %I_r_I_aa_r
        Total(:,13) = Theta_aa*I_r_s; %I_r_s_I_s_aa_r
        Total(:,14) = gamma_I_r_s*I_r_s; %I_s_o
        Total(:,15) = gamma_I_s_aa_r*I_s_aa_r; %I_s_aa_r_o
        Total(:,16) = k_aa_rr*q_s*I_s_aa_r; %%I_s_aa_r_I_s_aa_rr
        Total(:,17) = (beta_S_I_rr*I_rr + beta_S_I_rr_s*I_rr_s + beta_S_I_s_aa_rr*I_s_aa_rr + beta_S_I_aa_rr*I_aa_rr...
            + beta_S_I_v_rr*I_v_rr + beta_S_I_v_rr_s*I_v_rr_s + beta_S_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_I_v_aa_rr*I_v_aa_rr).*S; %S_I_rr
        Total(:,18) = delta_I_rr_I_rr_s*I_rr; %I_rr_I_rr_s
        Total(:,19) = gamma_I_rr*I_rr; %I_rr_o
        Total(:,20) = zeros(length(t),1); %I_rr_o
        Total(:,21) = Theta_aa*I_rr_s; %I_rr_s_I_s_aa_rr
        Total(:,22) = gamma_I_rr_s*I_rr_s; %I_rr_s_o
        Total(:,23) = gamma_I_s_aa_rr*I_s_aa_rr; %I_s_aa_rr_o
        Total(:,24) = zeros(length(t),1); %S_S_aa
        Total(:,25) = (beta_S_aa_I*I + beta_S_aa_I_s*I_s + beta_S_aa_I_s_aa*I_s_aa + beta_S_aa_I_aa*I_aa...
            + beta_S_aa_I_v*I_v + beta_S_aa_I_v_s*I_v_s + beta_S_aa_I_v_s_aa*I_v_s_aa + beta_S_aa_I_v_aa*I_v_aa).*S_aa; %S_aa_I__aa
        Total(:,26) = delta_I_aa_I_s_aa*I_aa; %I_aa_I_s_aa
        Total(:,27) = gamma_I_aa*I_aa; %I_aa_o
        Total(:,28) = k_aa_r*q*I_aa; %I_aa_I_aa_r
        Total(:,29) = (beta_S_aa_I_r*I_r + beta_S_aa_I_r_s*I_r_s + beta_S_aa_I_s_aa_r*I_s_aa_r + beta_S_aa_I_aa_r*I_aa_r...
            + beta_S_aa_I_v_r*I_v_r + beta_S_aa_I_v_r_s*I_v_r_s + beta_S_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_aa_I_v_aa_r*I_v_aa_r).*S_aa; %S_aa_I_aa_r
        Total(:,30) = delta_I_aa_r_I_s_aa_r*I_aa_r; %I_aa_r_I_s_aa_r
        Total(:,31) = gamma_I_aa_r*I_aa_r; %I_aa_r_o
        Total(:,32) = k_aa_rr*q*I_aa_r; %I_aa_r_I_aa_rr
        Total(:,33) = (beta_S_aa_I_rr*I_rr + beta_S_aa_I_rr_s*I_rr_s + beta_S_aa_I_s_aa_rr*I_s_aa_rr + beta_S_aa_I_aa_rr*I_aa_rr...
            + beta_S_aa_I_v_rr*I_v_rr + beta_S_aa_I_v_rr_s*I_v_rr_s + beta_S_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_aa_I_v_aa_rr*I_v_aa_rr).*S_aa; %S_aa_I_aa_rr
        Total(:,34) = delta_I_aa_rr_I_s_aa_rr*I_aa_rr; %I_aa_rr_I_s_aa_rr
        Total(:,35) = gamma_I_aa_rr*I_aa_rr; %I_aa_rr_o

        Total(:,36) = (beta_S_v_I*I + beta_S_v_I_s*I_s + beta_S_v_I_s_aa*I_s_aa + beta_S_v_I_aa*I_aa...
            + beta_S_v_I_v*I_v + beta_S_v_I_v_s*I_v_s + beta_S_v_I_v_s_aa*I_v_s_aa + beta_S_v_I_v_aa*I_v_aa).*S_v; %S_v_I_v
        Total(:,37) = delta_I_v_I_v_s*I_v; %I_v_I_v_s
        Total(:,38) = gamma_I_v*I_v; %I_v_o
        Total(:,39) = zeros(length(t),1); %I_v_I_v_aa
        Total(:,40) = [zeros(length(0:0.1:time_treat),1);Theta_aa*I_v_s((find(t==time_treat)+1):end)]; %I_v_s_I_v_s_aa
        Total(:,41) = gamma_I_v_s*I_v_s; %I_v_s_o
        Total(:,42) = gamma_I_v_s_aa*I_v_s_aa; %I_v_s_aa_o
        Total(:,43) = k_aa_r*q_s*I_v_s_aa; %I_v_s_aa_I_v_s_aa_r
        Total(:,44) = (beta_S_v_I_r*I_r + beta_S_v_I_r_s*I_r_s + beta_S_v_I_s_aa_r*I_s_aa_r + beta_S_v_I_aa_r*I_aa_r...
            + beta_S_v_I_v_r*I_v_r + beta_S_v_I_v_r_s*I_v_r_s + beta_S_v_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_I_v_aa_r*I_v_aa_r).*S_v; %S_v_I_v_r
        Total(:,45) = delta_I_v_r_I_v_r_s*I_v_r; %I_v_r_I_v_r_s
        Total(:,46) = gamma_I_v_r*I_v_r; %I_v_r_o
        Total(:,47) = zeros(length(t),1); %I_v_r_I_v_aa_r
        Total(:,48) = Theta_aa*I_v_r_s; %I_v_r_s_I_v_s_aa_r
        Total(:,49) = gamma_I_v_r_s*I_v_r_s; %I_v_r_s_o
        Total(:,50) = gamma_I_v_s_aa_r*I_v_s_aa_r; %I_v_s_aa_r_o
        Total(:,51) = k_aa_rr*q_s*I_v_s_aa_r; %%I_v_s_aa_r_I_v_s_aa_rr
        Total(:,52) = (beta_S_v_I_rr*I_rr + beta_S_v_I_rr_s*I_rr_s + beta_S_v_I_s_aa_rr*I_s_aa_rr + beta_S_v_I_aa_rr*I_aa_rr...
            + beta_S_v_I_v_rr*I_v_rr + beta_S_v_I_v_rr_s*I_v_rr_s + beta_S_v_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_I_v_aa_rr*I_v_aa_rr).*S_v; %S_v_I_v_rr
        Total(:,53) = delta_I_v_rr_I_v_rr_s*I_v_rr; %I_v_rr_I_v_rr_s
        Total(:,54) = gamma_I_v_rr*I_v_rr; %I_v_rr_o
        Total(:,55) = zeros(length(t),1); %I_v_rr_I_v_aa_rr
        Total(:,56) = Theta_aa*I_v_rr_s; %I_v_rr_s_I_v_s_aa_rr
        Total(:,57) = gamma_I_v_rr_s*I_v_rr_s; %I_v_rr_s_o
        Total(:,58) = gamma_I_v_s_aa_rr*I_v_s_aa_rr; %I_v_s_aa_rr_o
        Total(:,59) = zeros(length(t),1); %S_v_S_v_aa
        Total(:,60) = (beta_S_v_aa_I*I + beta_S_v_aa_I_s*I_s + beta_S_v_aa_I_s_aa*I_s_aa + beta_S_v_aa_I_aa*I_aa...
            + beta_S_v_aa_I_v*I_v + beta_S_v_aa_I_v_s*I_v_s + beta_S_v_aa_I_v_s_aa*I_v_s_aa + beta_S_v_aa_I_v_aa*I_v_aa).*S_v_aa; %S_v_aa_I_v_aa
        Total(:,61) = delta_I_v_aa_I_v_s_aa*I_v_aa; %I_v_aa_I_v_s_aa
        Total(:,62) = gamma_I_v_aa*I_v_aa; %I_v_aa_o
        Total(:,63) = k_aa_r*q*I_v_aa; %I_v_aa_I_v_aa_r
        Total(:,64) = (beta_S_v_aa_I_r*I_r + beta_S_v_aa_I_r_s*I_r_s + beta_S_v_aa_I_s_aa_r*I_s_aa_r + beta_S_v_aa_I_aa_r*I_aa_r...
            + beta_S_v_aa_I_v_r*I_v_r + beta_S_v_aa_I_v_r_s*I_v_r_s + beta_S_v_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_aa_I_v_aa_r*I_v_aa_r).*S_v_aa; %S_v_aa_I_v_aa_r
        Total(:,65) = delta_I_v_aa_r_I_v_s_aa_r*I_v_aa_r; %I_v_aa_r_I_v_s_aa_r
        Total(:,66) = gamma_I_v_aa_r*I_v_aa_r; %I_v_aa_r_o
        Total(:,67) = k_aa_rr*q*I_v_aa_r; %I_v_aa_r_I_v_aa_rr
        Total(:,68) = (beta_S_v_aa_I_rr*I_rr + beta_S_v_aa_I_rr_s*I_rr_s + beta_S_v_aa_I_s_aa_rr*I_s_aa_rr + beta_S_v_aa_I_aa_rr*I_aa_rr...
            + beta_S_v_aa_I_v_rr*I_v_rr + beta_S_v_aa_I_v_rr_s*I_v_rr_s + beta_S_v_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_aa_I_v_aa_rr*I_v_aa_rr).*S_v_aa; %S_v_aa_I_v_aa_rr
        Total(:,69) = delta_I_v_aa_rr_I_v_s_aa_rr*I_v_aa_rr; %I_v_aa_rr_I_v_s_aa_rr
        Total(:,70) = gamma_I_v_aa_rr*I_v_aa_rr; %I_v_aa_rr_o

        for i_Total = 1:size(Total,2)
            Total_All(i_Total,:) = [i_Total,round(trapz(t,Total(:,i_Total)))];
        end

        if i_scenario > 2 && isempty(ind) == 0
            Total_All(4,2) = round(I(ind)); %I_I_aa
            Total_All(5,2) = round(I_s(ind)); %I_s_I_s_aa
            % Total_All(12,2) = round(I_r(ind)); %I_r_I_aa_r
            % Total_All(20,2) = round(I_rr(ind)); %I_rr_I_aa_rr
            Total_All(24,2) = round(S(ind)); %S_S_aa
            Total_All(39,2) = round(I_v(ind)); %I_v_I_v_aa
            Total_All(40,2) = round(I_v_s(ind)); %I_v_s_I_v_s_aa
            % Total_All(47,2) = round(I_v_r(ind)); %I_v_r_I_v_aa_r
            % Total_All(55,2) = round(I_v_rr(ind)); %I_v_rr_I_v_aa_rr
            Total_All(59,2) = round(S_v(ind)); %S_v_S_v_aa
        end

        S_end = round(S(end));
        S_aa_end = round(S_aa(end));
        S_v_end = round(S_v(end));
        S_v_aa_end = round(S_v_aa(end));

        Total_S = S_end + S_aa_end + S_v_end + S_v_aa_end;
        Total_I = 1 + Total_All(1,2)...; %S_I
            + Total_All(9,2)...; %S_I_r
            + Total_All(17,2)...; %S_I_rr
            + Total_All(25,2)...; %S_aa_I_aa
            + Total_All(29,2)...; %S_aa_I_aa_r
            + Total_All(33,2)...; %S_aa_I_aa_rr
            + Total_All(1+35,2)...; %S_v_I_v
            + Total_All(9+35,2)...; %S_v_I_v_r
            + Total_All(17+35,2)...; %S_v_I_v_rr
            + Total_All(25+35,2)...; %S_v_aa_I_v_aa
            + Total_All(29+35,2)...; %S_v_aa_I_v_aa_r
            + Total_All(33+35,2); %S_v_aa_I_v_aa_rr

        Total_I_v = Total_All(1+35,2)...; %S_v_I_v
            + Total_All(9+35,2)...; %S_v_I_v_r
            + Total_All(17+35,2)...; %S_v_I_v_rr
            + Total_All(25+35,2)...; %S_v_aa_I_v_aa
            + Total_All(29+35,2)...; %S_v_aa_I_v_aa_r
            + Total_All(33+35,2); %S_v_aa_I_v_aa_rr

        Total_I_s = Total_All(2,2)... %I_I_s
            + Total_All(10,2)... %I_r_I_r_s
            + Total_All(18,2)... %I_rr_I_rr_s
            + Total_All(26,2)... %I_aa_I_s_aa
            + Total_All(30,2)... %I_aa_r_I_s_aa_r
            + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
            + Total_All(2+35,2)... %I_v_I_v_s
            + Total_All(10+35,2)... %I_v_r_I_v_r_s
            + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
            + Total_All(26+35,2)... %I_v_aa_I_v_s_aa
            + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
            + Total_All(34+35,2); %I_v_aa_rr_I_v_s_aa_rr

        Total_I_s_r_rr = Total_All(10,2)... %I_r_I_r_s
            + Total_All(18,2)... %I_rr_I_rr_s
            + Total_All(30,2)... %I_aa_r_I_s_aa_r
            + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
            + Total_All(8,2)...%I_s_aa_I_s_aa_r
            + Total_All(10+35,2)... %I_v_r_I_v_r_s
            + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
            + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
            + Total_All(34+35,2)... %I_v_aa_rr_I_v_s_aa_rr
            + Total_All(8+35,2); %I_v_s_aa_I_v_s_aa_r

        Total_I_s_r = Total_All(10,2)... %I_r_I_r_s
            + Total_All(30,2)... %I_aa_r_I_s_aa_r
            + Total_All(8,2)... %I_s_aa_I_s_aa_r
            + Total_All(10+35,2)... %I_v_r_I_v_r_s
            + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
            + Total_All(8+35,2); %I_v_s_aa_I_v_s_aa_r

        Total_I_s_rr = Total_All(18,2)... %I_rr_I_rr_s
            + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
            + Total_All(16,2)...%I_s_aa_I_s_aa_r
            + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
            + Total_All(34+35,2)... %I_v_aa_rr_I_v_s_aa_rr
            + Total_All(16+35,2); %I_v_s_aa_I_v_s_aa_r

        Total_I_r_rr = Total_All(9,2)... %S_I_r
            + Total_All(17,2)... %S_I_rr
            + Total_All(29,2)... %S_aa_I_r
            + Total_All(33,2)... %S_aa_I_rr
            + Total_All(8,2)... %I_s_aa_I_s_aa_r
            + Total_All(28,2)... %I_aa_I_aa_r
            + Total_All(9+35,2)... %S_v_I_v_r
            + Total_All(17+35,2)... %S_v_I_v_rr
            + Total_All(29+35,2)... %S_v_aa_I_v_r
            + Total_All(33+35,2)... %S_v_aa_I_v_rr
            + Total_All(8+35,2)... %I_v_s_aa_I_v_s_aa_r
            + Total_All(28+35,2); %I_v_aa_I_v_aa_r

        Total_I_r = Total_All(9,2)... %S_I_r
            + Total_All(29,2)... %S_aa_I_r
            + Total_All(8,2)... %I_s_aa_I_s_aa_r
            + Total_All(28,2)... %I_aa_I_aa_r
            + Total_All(9+35,2)... %S_v_I_v_r
            + Total_All(29+35,2)... %S_v_aa_I_v_r
            + Total_All(8+35,2)... %I_v_s_aa_I_v_s_aa_r
            + Total_All(28+35,2); %I_v_aa_I_v_aa_r

        Total_I_rr = Total_All(17,2)... %S_I_rr
            + Total_All(33,2)... %S_aa_I_rr
            + Total_All(16,2)... %I_s_aa_r_I_s_aa_rr
            + Total_All(32,2)... %I_aa_r_I_aa_rr
            + Total_All(17+35,2)... %S_v_I_v_rr
            + Total_All(33+35,2)... %S_v_aa_I_v_rr
            + Total_All(16+35,2)... %I_v_s_aa_r_I_v_s_aa_rr
            + Total_All(32+35,2); %I_v_aa_r_I_v_aa_rr

        Total_aa = Total_All(4,2)... %I_I_aa
            + Total_All(5,2)... %I_s_I_s_aa
            + Total_All(13,2)... %I_s_r_I_s_aa_r
            + Total_All(21,2)... %I_s_rr_I_s_aa_rr
            + Total_All(24,2)... %S_S_aa
            + Total_All(39,2)... %I_v_I_v_aa
            + Total_All(40,2)... %I_v_s_I_v_s_aa
            + Total_All(48,2)... %I_v_s_r_I_v_s_aa_r
            + Total_All(56,2)... %I_v_s_rr_I_v_s_aa_rr
            + Total_All(59,2); %S_v_S_v_aa

        T_mono{i_count}(i_test,:) = [Total_S, Total_I, Total_I_s, Total_I_r, Total_I_rr, Total_I_s_r, Total_I_s_rr, Total_aa];
    end

    if i_scenario == 1

        % subplot(4,1,1);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(I_all)+0.1*max(I_all)],'FaceColor',[cmap2(i_scenario+1,:),0.2],'EdgeColor','none')
        % hold on
        % plot(t,I_all,'-','Color','k','LineWidth',LW)
        % hold on
        %
        % subplot(4,1,2);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(Is_all)+0.1*max(Is_all)],'FaceColor',[cmap2(i_scenario+1,:),0.2],'EdgeColor','none')
        % hold on
        % plot(t,Is_all,'-','Color','k','LineWidth',LW)
        % hold on

    else

        subplot(2,1,1);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(max(I_all))+0.1*max(max(I_all))],'FaceColor',[225, 225, 225]./255,'EdgeColor','none')
        xline(time_treat,':','Color','k')
        hold on
        plot(t,I_all,'-','Color',cmap2(i_scenario,:),'LineWidth',LW)
        hold on
        % if i_test == 11
        %     yline(I_all_no)
        % end
        ylabel('all infected')
        set(get(gca,'YLabel'),'Rotation',0)
        xticks([])
  

        % subplot(4,1,2);
        % plot(t,Is_all,'-','Color',[180,180,180]./255,'LineWidth',LW)
        % hold on

        subplot(2,1,2);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(max(Ir_all))+0.1*max(max(Ir_all))],'FaceColor',[225, 225, 225]./255,'EdgeColor','none')
        xline(time_treat,':','Color','k')
        hold on
        plot(t,Ir_all,'-','Color',cmap2(i_scenario,:),'LineWidth',LW)
        hold on
        ylabel('shedding resistant virus')
        set(get(gca,'YLabel'),'Rotation',0)
        xticks([0,50,100])

        % subplot(4,1,4);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(max(Is_r_all))+0.1*max(max(Is_r_all))],'FaceColor',[180,180,180]./255,'EdgeColor','none')
        % % hold on
        % % plot(t,Is_r_all,'-','Color',[211/255,95/255,95/255],'LineWidth',LW)
        % % hold on
        xlabel("time (days)")

        fontname("Helvetica")
        fontsize(8,"points")

        box off
        set(eval(sprintf('h%d',i_count-1)), 'Position',  [100, 100, 300, 150])
        % saveas(eval(sprintf('h%d',i_count-1)),sprintf('Figure2%d_mono.pdf',i_count));

        for i_test = 1:11
            if i_count < 4
                i_rel_res_form = i_test-1;
                i_rel_trans_fit = 1;
                %define time span of analysis
                % tspan = 0:0.1:40;
            else
                i_rel_res_form = 1;
                i_rel_trans_fit = i_test-1;
                %define time span of analysis
                % tspan = 0:0.1:150;
            end

            for i_parrel = 1:length(pars.ParametersRel)
                if ~strcmp(pars.ParametersRel(i_parrel),"")
                    eval(strcat(pars.ParametersRel(i_parrel), "=", pars.ValuesComb(i_parrel), ";"));
                end
            end

            for i_par = 1:length(pars.Parameters)
                if strcmp(pars.ParameterDescriptionsComb(i_par),"")
                    eval(strcat(pars.Parameters(i_par), "=", pars.ValuesComb_Regoes(i_par), ";"));
                    eval(strcat("par_comb(i_par)", "=", pars.ValuesComb_Regoes(i_par), ";"));
                    if strcmp(pars.Parameters(i_par),"beta_S_I_r") || strcmp(pars.Parameters(i_par),"beta_S_I_r_s") %redefine beta_S_I_r or beta_S_I_r_s according to the tranmission fitness given by i_rel_trans_fit
                        eval(strcat(pars.Parameters(i_par), "=", "i_rel_trans_fit*", pars.ValuesComb(i_par), ";"));
                        eval(strcat("par_comb(i_par)", "=", "i_rel_trans_fit*", pars.ValuesComb(i_par), ";"));
                    end
                    if strcmp(pars.Parameters(i_par),"k_aa_r") %redefine k_aa_r to the resistance formation rate given by i_rel_res_form
                        eval(strcat(pars.Parameters(i_par), "=", "i_rel_res_form*", pars.ValuesComb(i_par), ";"));
                        eval(strcat("par_comb(i_par)", "=", "i_rel_res_form*", pars.ValuesComb(i_par), ";"));
                    end
                else %also redefine the rates potententially dependent on the previously redefined parameters
                    eval(strcat(pars.Parameters(i_par), "=", pars.ParameterDescriptionsComb(i_par), ";"));
                    eval(strcat("par_comb(i_par)", "=", pars.ParameterDescriptionsComb(i_par), ";"));
                end
            end

            if isempty(ind) %if no detection of epidemic, no treatment, no need to rerun
                y_comb = y1;
                t_comb = t1;
            else
                tspan2 = 0:0.1:(max(tspan)-time_treat); %redefine time frame for evaluation (time left between treatment initiation and max(tspan))
                [t2,y2] = ode45(@(t,y) odefcn_influenza_after_Theta_pr(t,y,par_comb),tspan2,y0_2,options); %resolve ODE this time WITH treatment
                y_comb = [y1(1:ind,:);y2(2:end,:)]; %summarize the dynamics before and after treatment
                t_comb = [t1(1:ind);t2(2:end)+time_treat];

                %redefine the results from y1 to population names (for
                %understanding)
                for i_y = 1:size(y_comb,2)
                    eval(strcat(states0.States(i_y), "=", "y_comb(:,i_y);"));
                end
            end

            if i_test == 1
                if i_count > 1
                    figure(eval(sprintf('h%d',i_count+4-1)))
                end
            end

            %determine fdifferent subpopulaitons
            I_all(i_test,:) = I+I_s+I_aa+I_s_aa+I_r+I_r_s+I_aa_r+I_s_aa_r+I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
                +I_v+I_v_s+I_v_aa+I_v_s_aa+I_v_r+I_v_r_s+I_v_aa_r+...
                I_v_s_aa_r+I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected individuals
            Is_all(i_test,:) = I_s+I_s_aa+I_r_s+I_s_aa_r+I_rr_s+I_s_aa_rr...
                +I_v_s+I_v_s_aa+I_v_r_s+I_v_s_aa_r+I_v_rr_s+I_v_s_aa_rr; %all infected individuals with clinical symptoms (detectable)
            Ir_rr_all(i_test,:) = I_r+I_r_s+I_aa_r+I_s_aa_r+I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
                +I_v_r+I_v_r_s+I_v_aa_r+I_v_s_aa_r+I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
            Is_r_rr_all(i_test,:) = I_r_s+I_s_aa_r+I_rr_s+I_s_aa_rr...
                +I_v_r_s+I_v_s_aa_r+I_v_rr_s+I_v_s_aa_rr; %all infected individuals with clinical symptoms (detectable) shedding resistant virus (single or double resistant in case of combination therapy)
            Ir_all(i_test,:) = I_r+I_r_s+I_aa_r+I_s_aa_r...
                +I_v_r+I_v_r_s+I_v_aa_r+I_v_s_aa_r; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
            Is_r_all(i_test,:) = I_r_s+I_s_aa_r...
                +I_v_r_s+I_v_s_aa_r; %all infected indivdiauls shedding resistant virus (single or double resistant in case of combination therapy)
            Irr_all(i_test,:) = I_rr+I_rr_s+I_aa_rr+I_s_aa_rr...
                +I_v_rr+I_v_rr_s+I_v_aa_rr+I_v_s_aa_rr; %all infected individuals shedding double resistant virus (only relevant if combination therapy applied)
            Is_rr_all(i_test,:) = I_rr_s+I_s_aa_rr+I_v_rr_s+I_v_s_aa_rr; %all infected individuals shedding double resistant virus (only relevant if combination therapy applied)

            %for each population, define the total number of
            %indiviudals
            Total(:,1) = (beta_S_I*I + beta_S_I_s*I_s + beta_S_I_s_aa*I_s_aa + beta_S_I_aa*I_aa...
                + beta_S_I_v*I_v + beta_S_I_v_s*I_v_s + beta_S_I_v_s_aa*I_v_s_aa + beta_S_I_v_aa*I_v_aa).*S; %S_I
            Total(:,2) = delta_I_I_s*I; %I_I_s
            Total(:,3) = gamma_I*I; %I_o
            Total(:,4) = zeros(length(t),1); %I_I_aa
            Total(:,5) = [zeros(length(0:0.1:time_treat),1);Theta_aa*I_s((find(t==time_treat)+1):end)]; %I_s_I_s_aa
            Total(:,6) = gamma_I_s*I_s; %I_s_o
            Total(:,7) = gamma_I_s_aa*I_s_aa; %I_s_aa_o
            Total(:,8) = k_aa_r*q_s*I_s_aa; %I_s_aa_I_s_aa_r
            Total(:,9) = (beta_S_I_r*I_r + beta_S_I_r_s*I_r_s + beta_S_I_s_aa_r*I_s_aa_r + beta_S_I_aa_r*I_aa_r...
                + beta_S_I_v_r*I_v_r + beta_S_I_v_r_s*I_v_r_s + beta_S_I_v_s_aa_r*I_v_s_aa_r + beta_S_I_v_aa_r*I_v_aa_r).*S; %S_I_r
            Total(:,10) = delta_I_r_I_r_s*I_r; %I_r_I_r_s
            Total(:,11) = gamma_I_r*I_r; %I_r_o
            Total(:,12) = zeros(length(t),1); %I_r_I_aa_r
            Total(:,13) = Theta_aa*I_r_s; %I_r_s_I_s_aa_r
            Total(:,14) = gamma_I_r_s*I_r_s; %I_s_o
            Total(:,15) = gamma_I_s_aa_r*I_s_aa_r; %I_s_aa_r_o
            Total(:,16) = k_aa_rr*q_s*I_s_aa_r; %%I_s_aa_r_I_s_aa_rr
            Total(:,17) = (beta_S_I_rr*I_rr + beta_S_I_rr_s*I_rr_s + beta_S_I_s_aa_rr*I_s_aa_rr + beta_S_I_aa_rr*I_aa_rr...
                + beta_S_I_v_rr*I_v_rr + beta_S_I_v_rr_s*I_v_rr_s + beta_S_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_I_v_aa_rr*I_v_aa_rr).*S; %S_I_rr
            Total(:,18) = delta_I_rr_I_rr_s*I_rr; %I_rr_I_rr_s
            Total(:,19) = gamma_I_rr*I_rr; %I_rr_o
            Total(:,20) = zeros(length(t),1); %I_rr_o
            Total(:,21) = Theta_aa*I_rr_s; %I_rr_s_I_s_aa_rr
            Total(:,22) = gamma_I_rr_s*I_rr_s; %I_rr_s_o
            Total(:,23) = gamma_I_s_aa_rr*I_s_aa_rr; %I_s_aa_rr_o
            Total(:,24) = zeros(length(t),1); %S_S_aa
            Total(:,25) = (beta_S_aa_I*I + beta_S_aa_I_s*I_s + beta_S_aa_I_s_aa*I_s_aa + beta_S_aa_I_aa*I_aa...
                + beta_S_aa_I_v*I_v + beta_S_aa_I_v_s*I_v_s + beta_S_aa_I_v_s_aa*I_v_s_aa + beta_S_aa_I_v_aa*I_v_aa).*S_aa; %S_aa_I__aa
            Total(:,26) = delta_I_aa_I_s_aa*I_aa; %I_aa_I_s_aa
            Total(:,27) = gamma_I_aa*I_aa; %I_aa_o
            Total(:,28) = k_aa_r*q*I_aa; %I_aa_I_aa_r
            Total(:,29) = (beta_S_aa_I_r*I_r + beta_S_aa_I_r_s*I_r_s + beta_S_aa_I_s_aa_r*I_s_aa_r + beta_S_aa_I_aa_r*I_aa_r...
                + beta_S_aa_I_v_r*I_v_r + beta_S_aa_I_v_r_s*I_v_r_s + beta_S_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_aa_I_v_aa_r*I_v_aa_r).*S_aa; %S_aa_I_aa_r
            Total(:,30) = delta_I_aa_r_I_s_aa_r*I_aa_r; %I_aa_r_I_s_aa_r
            Total(:,31) = gamma_I_aa_r*I_aa_r; %I_aa_r_o
            Total(:,32) = k_aa_rr*q*I_aa_r; %I_aa_r_I_aa_rr
            Total(:,33) = (beta_S_aa_I_rr*I_rr + beta_S_aa_I_rr_s*I_rr_s + beta_S_aa_I_s_aa_rr*I_s_aa_rr + beta_S_aa_I_aa_rr*I_aa_rr...
                + beta_S_aa_I_v_rr*I_v_rr + beta_S_aa_I_v_rr_s*I_v_rr_s + beta_S_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_aa_I_v_aa_rr*I_v_aa_rr).*S_aa; %S_aa_I_aa_rr
            Total(:,34) = delta_I_aa_rr_I_s_aa_rr*I_aa_rr; %I_aa_rr_I_s_aa_rr
            Total(:,35) = gamma_I_aa_rr*I_aa_rr; %I_aa_rr_o

            Total(:,36) = (beta_S_v_I*I + beta_S_v_I_s*I_s + beta_S_v_I_s_aa*I_s_aa + beta_S_v_I_aa*I_aa...
                + beta_S_v_I_v*I_v + beta_S_v_I_v_s*I_v_s + beta_S_v_I_v_s_aa*I_v_s_aa + beta_S_v_I_v_aa*I_v_aa).*S_v; %S_v_I_v
            Total(:,37) = delta_I_v_I_v_s*I_v; %I_v_I_v_s
            Total(:,38) = gamma_I_v*I_v; %I_v_o
            Total(:,39) = zeros(length(t),1); %I_v_I_v_aa
            Total(:,40) = [zeros(length(0:0.1:time_treat),1);Theta_aa*I_v_s((find(t==time_treat)+1):end)]; %I_v_s_I_v_s_aa
            Total(:,41) = gamma_I_v_s*I_v_s; %I_v_s_o
            Total(:,42) = gamma_I_v_s_aa*I_v_s_aa; %I_v_s_aa_o
            Total(:,43) = k_aa_r*q_s*I_v_s_aa; %I_v_s_aa_I_v_s_aa_r
            Total(:,44) = (beta_S_v_I_r*I_r + beta_S_v_I_r_s*I_r_s + beta_S_v_I_s_aa_r*I_s_aa_r + beta_S_v_I_aa_r*I_aa_r...
                + beta_S_v_I_v_r*I_v_r + beta_S_v_I_v_r_s*I_v_r_s + beta_S_v_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_I_v_aa_r*I_v_aa_r).*S_v; %S_v_I_v_r
            Total(:,45) = delta_I_v_r_I_v_r_s*I_v_r; %I_v_r_I_v_r_s
            Total(:,46) = gamma_I_v_r*I_v_r; %I_v_r_o
            Total(:,47) = zeros(length(t),1); %I_v_r_I_v_aa_r
            Total(:,48) = Theta_aa*I_v_r_s; %I_v_r_s_I_v_s_aa_r
            Total(:,49) = gamma_I_v_r_s*I_v_r_s; %I_v_r_s_o
            Total(:,50) = gamma_I_v_s_aa_r*I_v_s_aa_r; %I_v_s_aa_r_o
            Total(:,51) = k_aa_rr*q_s*I_v_s_aa_r; %%I_v_s_aa_r_I_v_s_aa_rr
            Total(:,52) = (beta_S_v_I_rr*I_rr + beta_S_v_I_rr_s*I_rr_s + beta_S_v_I_s_aa_rr*I_s_aa_rr + beta_S_v_I_aa_rr*I_aa_rr...
                + beta_S_v_I_v_rr*I_v_rr + beta_S_v_I_v_rr_s*I_v_rr_s + beta_S_v_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_I_v_aa_rr*I_v_aa_rr).*S_v; %S_v_I_v_rr
            Total(:,53) = delta_I_v_rr_I_v_rr_s*I_v_rr; %I_v_rr_I_v_rr_s
            Total(:,54) = gamma_I_v_rr*I_v_rr; %I_v_rr_o
            Total(:,55) = zeros(length(t),1); %I_v_rr_I_v_aa_rr
            Total(:,56) = Theta_aa*I_v_rr_s; %I_v_rr_s_I_v_s_aa_rr
            Total(:,57) = gamma_I_v_rr_s*I_v_rr_s; %I_v_rr_s_o
            Total(:,58) = gamma_I_v_s_aa_rr*I_v_s_aa_rr; %I_v_s_aa_rr_o
            Total(:,59) = zeros(length(t),1); %S_v_S_v_aa
            Total(:,60) = (beta_S_v_aa_I*I + beta_S_v_aa_I_s*I_s + beta_S_v_aa_I_s_aa*I_s_aa + beta_S_v_aa_I_aa*I_aa...
                + beta_S_v_aa_I_v*I_v + beta_S_v_aa_I_v_s*I_v_s + beta_S_v_aa_I_v_s_aa*I_v_s_aa + beta_S_v_aa_I_v_aa*I_v_aa).*S_v_aa; %S_v_aa_I_v_aa
            Total(:,61) = delta_I_v_aa_I_v_s_aa*I_v_aa; %I_v_aa_I_v_s_aa
            Total(:,62) = gamma_I_v_aa*I_v_aa; %I_v_aa_o
            Total(:,63) = k_aa_r*q*I_v_aa; %I_v_aa_I_v_aa_r
            Total(:,64) = (beta_S_v_aa_I_r*I_r + beta_S_v_aa_I_r_s*I_r_s + beta_S_v_aa_I_s_aa_r*I_s_aa_r + beta_S_v_aa_I_aa_r*I_aa_r...
                + beta_S_v_aa_I_v_r*I_v_r + beta_S_v_aa_I_v_r_s*I_v_r_s + beta_S_v_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_aa_I_v_aa_r*I_v_aa_r).*S_v_aa; %S_v_aa_I_v_aa_r
            Total(:,65) = delta_I_v_aa_r_I_v_s_aa_r*I_v_aa_r; %I_v_aa_r_I_v_s_aa_r
            Total(:,66) = gamma_I_v_aa_r*I_v_aa_r; %I_v_aa_r_o
            Total(:,67) = k_aa_rr*q*I_v_aa_r; %I_v_aa_r_I_v_aa_rr
            Total(:,68) = (beta_S_v_aa_I_rr*I_rr + beta_S_v_aa_I_rr_s*I_rr_s + beta_S_v_aa_I_s_aa_rr*I_s_aa_rr + beta_S_v_aa_I_aa_rr*I_aa_rr...
                + beta_S_v_aa_I_v_rr*I_v_rr + beta_S_v_aa_I_v_rr_s*I_v_rr_s + beta_S_v_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_aa_I_v_aa_rr*I_v_aa_rr).*S_v_aa; %S_v_aa_I_v_aa_rr
            Total(:,69) = delta_I_v_aa_rr_I_v_s_aa_rr*I_v_aa_rr; %I_v_aa_rr_I_v_s_aa_rr
            Total(:,70) = gamma_I_v_aa_rr*I_v_aa_rr; %I_v_aa_rr_o

            for i_Total = 1:size(Total,2)
                Total_All(i_Total,:) = [i_Total,round(trapz(t,Total(:,i_Total)))];
            end

            if i_scenario > 2 && isempty(ind) == 0
                Total_All(4,2) = round(I(ind)); %I_I_aa
                Total_All(5,2) = round(I_s(ind)); %I_s_I_s_aa
                % Total_All(12,2) = round(I_r(ind)); %I_r_I_aa_r
                % Total_All(20,2) = round(I_rr(ind)); %I_rr_I_aa_rr
                Total_All(24,2) = round(S(ind)); %S_S_aa
                Total_All(39,2) = round(I_v(ind)); %I_v_I_v_aa
                Total_All(40,2) = round(I_v_s(ind)); %I_v_s_I_v_s_aa
                % Total_All(47,2) = round(I_v_r(ind)); %I_v_r_I_v_aa_r
                % Total_All(55,2) = round(I_v_rr(ind)); %I_v_rr_I_v_aa_rr
                Total_All(59,2) = round(S_v(ind)); %S_v_S_v_aa
            end

            S_end = round(S(end));
            S_aa_end = round(S_aa(end));
            S_v_end = round(S_v(end));
            S_v_aa_end = round(S_v_aa(end));

            Total_S = S_end + S_aa_end + S_v_end + S_v_aa_end;
            Total_I = 1 + Total_All(1,2)...; %S_I
                + Total_All(9,2)...; %S_I_r
                + Total_All(17,2)...; %S_I_rr
                + Total_All(25,2)...; %S_aa_I_aa
                + Total_All(29,2)...; %S_aa_I_aa_r
                + Total_All(33,2)...; %S_aa_I_aa_rr
                + Total_All(1+35,2)...; %S_v_I_v
                + Total_All(9+35,2)...; %S_v_I_v_r
                + Total_All(17+35,2)...; %S_v_I_v_rr
                + Total_All(25+35,2)...; %S_v_aa_I_v_aa
                + Total_All(29+35,2)...; %S_v_aa_I_v_aa_r
                + Total_All(33+35,2); %S_v_aa_I_v_aa_rr

            Total_I_v = Total_All(1+35,2)...; %S_v_I_v
                + Total_All(9+35,2)...; %S_v_I_v_r
                + Total_All(17+35,2)...; %S_v_I_v_rr
                + Total_All(25+35,2)...; %S_v_aa_I_v_aa
                + Total_All(29+35,2)...; %S_v_aa_I_v_aa_r
                + Total_All(33+35,2); %S_v_aa_I_v_aa_rr

            Total_I_s = Total_All(2,2)... %I_I_s
                + Total_All(10,2)... %I_r_I_r_s
                + Total_All(18,2)... %I_rr_I_rr_s
                + Total_All(26,2)... %I_aa_I_s_aa
                + Total_All(30,2)... %I_aa_r_I_s_aa_r
                + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
                + Total_All(2+35,2)... %I_v_I_v_s
                + Total_All(10+35,2)... %I_v_r_I_v_r_s
                + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
                + Total_All(26+35,2)... %I_v_aa_I_v_s_aa
                + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
                + Total_All(34+35,2); %I_v_aa_rr_I_v_s_aa_rr

            Total_I_s_r_rr = Total_All(10,2)... %I_r_I_r_s
                + Total_All(18,2)... %I_rr_I_rr_s
                + Total_All(30,2)... %I_aa_r_I_s_aa_r
                + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
                + Total_All(8,2)...%I_s_aa_I_s_aa_r
                + Total_All(10+35,2)... %I_v_r_I_v_r_s
                + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
                + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
                + Total_All(34+35,2)... %I_v_aa_rr_I_v_s_aa_rr
                + Total_All(8+35,2); %I_v_s_aa_I_v_s_aa_r

            Total_I_s_r = Total_All(10,2)... %I_r_I_r_s
                + Total_All(30,2)... %I_aa_r_I_s_aa_r
                + Total_All(8,2)... %I_s_aa_I_s_aa_r
                + Total_All(10+35,2)... %I_v_r_I_v_r_s
                + Total_All(30+35,2)... %I_v_aa_r_I_v_s_aa_r
                + Total_All(8+35,2); %I_v_s_aa_I_v_s_aa_r

            Total_I_s_rr = Total_All(18,2)... %I_rr_I_rr_s
                + Total_All(34,2)... %I_aa_rr_I_s_aa_rr
                + Total_All(16,2)...%I_s_aa_I_s_aa_r
                + Total_All(18+35,2)... %I_v_rr_I_v_rr_s
                + Total_All(34+35,2)... %I_v_aa_rr_I_v_s_aa_rr
                + Total_All(16+35,2); %I_v_s_aa_I_v_s_aa_r

            Total_I_r_rr = Total_All(9,2)... %S_I_r
                + Total_All(17,2)... %S_I_rr
                + Total_All(29,2)... %S_aa_I_r
                + Total_All(33,2)... %S_aa_I_rr
                + Total_All(8,2)... %I_s_aa_I_s_aa_r
                + Total_All(28,2)... %I_aa_I_aa_r
                + Total_All(9+35,2)... %S_v_I_v_r
                + Total_All(17+35,2)... %S_v_I_v_rr
                + Total_All(29+35,2)... %S_v_aa_I_v_r
                + Total_All(33+35,2)... %S_v_aa_I_v_rr
                + Total_All(8+35,2)... %I_v_s_aa_I_v_s_aa_r
                + Total_All(28+35,2); %I_v_aa_I_v_aa_r

            Total_I_r = Total_All(9,2)... %S_I_r
                + Total_All(29,2)... %S_aa_I_r
                + Total_All(8,2)... %I_s_aa_I_s_aa_r
                + Total_All(28,2)... %I_aa_I_aa_r
                + Total_All(9+35,2)... %S_v_I_v_r
                + Total_All(29+35,2)... %S_v_aa_I_v_r
                + Total_All(8+35,2)... %I_v_s_aa_I_v_s_aa_r
                + Total_All(28+35,2); %I_v_aa_I_v_aa_r

            Total_I_rr = Total_All(17,2)... %S_I_rr
                + Total_All(33,2)... %S_aa_I_rr
                + Total_All(16,2)... %I_s_aa_r_I_s_aa_rr
                + Total_All(32,2)... %I_aa_r_I_aa_rr
                + Total_All(17+35,2)... %S_v_I_v_rr
                + Total_All(33+35,2)... %S_v_aa_I_v_rr
                + Total_All(16+35,2)... %I_v_s_aa_r_I_v_s_aa_rr
                + Total_All(32+35,2); %I_v_aa_r_I_v_aa_rr

            Total_aa = Total_All(4,2)... %I_I_aa
                + Total_All(5,2)... %I_s_I_s_aa
                + Total_All(13,2)... %I_s_r_I_s_aa_r
                + Total_All(21,2)... %I_s_rr_I_s_aa_rr
                + Total_All(24,2)... %S_S_aa
                + Total_All(39,2)... %I_v_I_v_aa
                + Total_All(40,2)... %I_v_s_I_v_s_aa
                + Total_All(48,2)... %I_v_s_r_I_v_s_aa_r
                + Total_All(56,2)... %I_v_s_rr_I_v_s_aa_rr
                + Total_All(59,2); %S_v_S_v_aa

            T_comb{i_count}(i_test,:) = [Total_S, Total_I, Total_I_s, Total_I_r, Total_I_rr, Total_I_s_r, Total_I_s_rr, Total_aa];

        end

        subplot(2,1,1);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(max(I_all))+0.1*max(max(I_all))],'FaceColor',[225, 225, 225]./255,'EdgeColor','none')
        xline(time_treat,':','Color','k')
        hold on
        plot(t,I_all,'-','Color',cmap2(i_scenario,:),'LineWidth',LW)
        hold on
        % if i_test == 11
        %    yline(I_all_no)
        % end
        xticks([])
        ylabel('all infected')
        set(get(gca,'YLabel'),'Rotation',0)

        % subplot(4,1,2);
        % plot(t,Is_all,'--','Color',[180,180,180]./255,'LineWidth',LW)
        % hold on
        % xticks([0,10,20,30,40])
        % xticks([])
        % yticks([0,100,200])

        subplot(2,1,2);
        % rectangle('Position',[time_treat 0 max(tspan)-time_treat max(max(Irr_all))+0.1*max(max(Irr_all))],'FaceColor',[225, 225, 225]./255,'EdgeColor','none')
        xline(time_treat,':','Color','k')
        hold on
        plot(t,Irr_all,'-','Color',cmap2(i_scenario,:),'LineWidth',LW)
        hold on
        xticks([0,50,100])
        ylabel('shedding resistant virus')
        set(get(gca,'YLabel'),'Rotation',0)

        xlabel("time (days)")

        fontname("Helvetica")
        fontsize(8,"points")

        box off
        set(eval(sprintf('h%d',i_count+4-1)), 'Position',  [100, 100, 300, 150])
        % saveas(eval(sprintf('h%d',i_count+4-1)),sprintf('Figure2%d_comb.pdf',i_count));

    end

    i_count = i_count + 1;

end

cmap_mono= [0, 0, 0;
    207, 207, 242; %blue light
    209, 242, 221]./255; %green light

cmap_comb = [0, 0, 0;
    142, 142, 224; %blue
    161, 228, 186]./255; %green

figure
for i = 1:3
    plot(0:10,T_mono{i}(:,2),'-', 'Color',cmap_mono(i,:), 'Linewidth', LW)
    hold on
    if i > 1
        plot(0:10,T_comb{i}(:,2),'-','Color',cmap_comb(i,:), 'Linewidth', LW)
        hold on
    end
end
ylim([0,1000])
xlim([0,10])
box off
yticks([0,500,1000])
xticks([0:2:10])
set(gcf, 'Position',  [100, 100, 200,150])
% saveas(gcf,'Figure2A.pdf');

figure
for i = 2:3
    plot(0:10,T_mono{i}(:,4),'-','Color',cmap_mono(i,:), 'Linewidth', LW)
    hold on
    if i > 1
        plot(0:10,T_comb{i}(:,5),'-','Color',cmap_comb(i,:), 'Linewidth', LW)
        hold on
    end
end
ylim([0,1000])
xlim([0,10])
box off
yticks([0,500,1000])
xticks([0:2:10])
set(gcf, 'Position',  [100, 100, 200, 150])
% saveas(gcf,'Figure2B.pdf');

cmap_all = [0, 0, 0; %black
            207, 207, 242; %blue light
            142, 142, 224; %blue
            209, 242, 221; %green light
            161, 228, 186]./255; %green

figure
i_count = 1;
for i = [1,4,5]
    plot(0:10,T_mono{i}(:,2),'-','Color', cmap_all(i_count,:), 'Linewidth', LW)
    i_count = i_count+1;
    hold on
    if i > 1
        plot(0:10,T_comb{i}(:,2),'-','Color', cmap_all(i_count,:), 'Linewidth', LW)
        i_count = i_count+1;
        hold on
    end
end
ylim([0,1000])
xlim([0,10])
box off
yticks([0,500,1000])
xticks([0:2:10])
set(gcf, 'Position',  [100, 100, 200,150])
% saveas(gcf,'Figure2C.pdf');

i_count = 2;
figure
for i = [4,5]
    plot(0:10,T_mono{i}(:,4),'-','Color', cmap_all(i_count,:), 'Linewidth', LW)
    i_count = i_count+1;
    hold on
    if i > 1
        plot(0:10,T_comb{i}(:,5),'-','Color', cmap_all(i_count,:), 'Linewidth', LW)
        i_count = i_count+1;
        hold on
    end
end
ylim([0,1000])
xlim([0,10])
box off
yticks([0,500,1000])
xticks([0:2:10])
set(gcf, 'Position',  [100, 100, 200,150])
% saveas(gcf,'Figure2D.pdf');

get_R_all(1,1,1,0)
%saveas(gcf,'FigureS1H.pdf');

