function get_R_all(plot1,plot2,plot3,plot4)
%% set script
clearvars -except plot1 plot2 plot3 plot4
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


for i_parrel = 1:length(pars.ParametersRel)
    if ~strcmp(pars.ParametersRel(i_parrel),"")
        eval(strcat(pars.ParametersRel(i_parrel), "=", pars.ValuesMono(i_parrel), ";"));
    end
end

for i_par = 1:length(pars.Parameters)
    if strcmp(pars.ParameterDescriptionsMono(i_par),"")
        eval(strcat(pars.Parameters(i_par), "=", pars.ValuesMono(i_par), ";"));
        eval(strcat("par_mono(i_par)", "=", pars.ValuesMono(i_par), ";"));
    elseif strcmp(pars.ParameterDescriptionsMono(i_par),"NaN")
        eval(strcat(pars.Parameters(i_par), "=", "0", ";"));
        eval(strcat("par_mono(i_par)", "=", "0", ";"));
    else
        eval(strcat(pars.Parameters(i_par), "=", pars.ParameterDescriptionsMono(i_par), ";"));
        eval(strcat("par_mono(i_par)", "=", pars.ParameterDescriptionsMono(i_par), ";"));
    end
end

%no vacc, no treat, I
R(1,1) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (beta_S_I ...
    + delta_I_I_s/(gamma_I_s)*(beta_S_I_s));

%no vacc, mono treat, I
R(2,1) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (beta_S_I ...
    + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
    + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa)));

R(2,2) = (S0+S_v0) / (delta_I_I_s + gamma_I)...
    * (delta_I_I_s/(Theta_aa + gamma_I_s)...
    *(Theta_aa / (gamma_I_s_aa + k_aa_r * q_s)...
    * (k_aa_r*q_s / (gamma_I_s_aa_r) * (beta_S_I_s_aa_r))));

R_check(2) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (beta_S_I ...
    + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
    + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa...
    + k_aa_r*q_s / (gamma_I_s_aa_r) * (beta_S_I_s_aa_r))));

%no vacc, mono proph, I
R(4,1) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
    + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa));

R(4,2) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (...
    delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (...
    k_aa_r * q_s /(gamma_I_s_aa_r)* (beta_S_aa_I_s_aa_r))...
    + k_aa_r * q / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (beta_S_aa_I_s_aa_r)));

R_check(4) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
    + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa...
    + k_aa_r * q_s /(gamma_I_s_aa_r)* (beta_S_aa_I_s_aa_r))...
    + k_aa_r * q / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (beta_S_aa_I_s_aa_r)));

%no vacc, mono treat, I_r
R(6,2) = (S0+S_v0) / (delta_I_r_I_r_s + gamma_I_r) * (beta_S_I_r ...
    + delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(beta_S_I_r_s...
    + Theta_aa / (gamma_I_s_aa_r) * (beta_S_I_s_aa_r)));

%no vacc, mono proph, I_r
R(8,2) = (S0+S_v0) / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (beta_S_aa_I_s_aa_r));

if plot1 == 1
    h1 = figure;
end
if plot2 == 1
    h2 = figure;
end
if plot3 == 1
    h3 = figure;
end

LW = 1.5;

if plot1 == 1
    figure(h1)
end
for i = 0:10
    denovo_res = (k_aa_r * q_s) * i;

    R_mono_k(1,i+1) = (S0+S_v0) / (delta_I_I_s + gamma_I)...
        * (delta_I_I_s/(Theta_aa + gamma_I_s)...
        *(Theta_aa / (gamma_I_s_aa + denovo_res)...
        * (denovo_res / (gamma_I_s_aa_r) * (beta_S_I_s_aa_r))));

    R_mono_k(2,i+1)  = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + denovo_res/10) * (...
        delta_I_aa_I_s_aa / (gamma_I_s_aa + denovo_res) * (...
        denovo_res /(gamma_I_s_aa_r)* (beta_S_aa_I_s_aa_r))...
        + denovo_res/10 / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (beta_S_aa_I_aa_r...
        + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (beta_S_aa_I_s_aa_r)));
end
if plot1 == 1
    plot(0:10,R_mono_k(1,:),'-','Color', [207, 207, 242]./255, 'LineWidth',LW)
    hold on
    plot(0:10,R_mono_k(2,:),'-','Color', [209, 242, 221]./255, 'LineWidth',LW)
    hold on
    yline(1,'LineWidth',LW)
    hold on
end

if plot2 == 1
    figure(h2)
end
for i = 0:10
    trans_res_S_I_r = beta_S_I_r * i;
    trans_res_S_I_r_s = beta_S_I_r_s * i;
    trans_res_S_I_s_aa_r = beta_S_I_s_aa_r * i;
    trans_res_S_aa_I_aa_r = beta_S_aa_I_aa_r * i;
    trans_res_S_aa_I_s_aa_r = beta_S_aa_I_s_aa_r * i;

    R_mono_b(1,i+1) = (S0+S_v0) / (delta_I_r_I_r_s + gamma_I_r) * (trans_res_S_I_r ...
        + delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(trans_res_S_I_r_s...
        + Theta_aa / (gamma_I_s_aa_r) * (trans_res_S_I_s_aa_r)));

    R_mono_b(2,i+1)  = (S0+S_v0) / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (trans_res_S_aa_I_aa_r ...
        + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (trans_res_S_aa_I_s_aa_r));
end
if plot2 == 1
    plot(0:10,R_mono_b(1,:),'-','Color', [207, 207, 242]./255,'LineWidth',LW)
    hold on
    plot(0:10,R_mono_b(2,:),'-','Color', [209, 242, 221]./255,'LineWidth',LW)
    hold on
    yline(1,'LineWidth',LW)
    hold on
end

for i_parrel = 1:length(pars.ParametersRel)
    if ~strcmp(pars.ParametersRel(i_parrel),"")
        eval(strcat(pars.ParametersRel(i_parrel), "=", pars.ValuesMono(i_parrel), ";"));
    end
end

i_rel_trans_fit = 10;
i_rel_res_form = 1;

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

if plot3 == 1
    figure(h3)
end

tspan = 0:0.1:100;

%extract the initial values and re-structure in one vector y0
y0 = [];
for i_states = 1:length(states0.States)
    y0 = [y0; eval(strcat(states0.States(i_states), "0"), ";")];
end

y0(1) = S0+S_v0;
y0(15) = 0;

options = odeset('NonNegative',1:length(y0)); %specify non-negative values for ODE solver
[t1,y1] = ode45(@(t,y) odefcn_influenza_before_Theta_pr(t,y,par_mono),tspan,y0,options); %solve ODE

%redefine the results from y1 to population names (for
%understanding)
for i_y = 1:size(y1,2)
    eval(strcat(states0.States(i_y), "=", "y1(:,i_y);"));
end

f_Total_I_s_all =  (delta_I_I_s*I + delta_I_v_I_v_s*I_v)/10; %calulate the number of infected individuals with clinical symptoms
ind = find(cumsum(f_Total_I_s_all) > 0.05*(S0+S_v0+1),1,"first"); %find the time point at which this number exceeds 5% of the population

if isempty(ind) == 0 %if this threshold is reached, set a potential initiation of treatment to that time point
    time_treat = t1(ind);
else
    time_treat = max(tspan); %if this threshold is not reached, no treatment during time span of analysis
end

for i_scenario = [2,3]
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

    if i_scenario == 2

        R_mono_S_r(1,:) = ([zeros(ind-1,1);S(ind:end)])  / (delta_I_r_I_r_s + gamma_I_r) * (trans_res_S_I_r ...
            + delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(trans_res_S_I_r_s...
            + Theta_aa / (gamma_I_s_aa_r) * (trans_res_S_I_s_aa_r)));

        R_mono_S_i(1,1:ind-1) = S(1:ind-1) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(gamma_I_s)*(beta_S_I_s));

        R_mono_S_i(1,ind:length(tspan))  = [S(ind:end) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
            + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa)))]';

    elseif i_scenario == 3
        R_mono_S_r(2,:)  = S_aa / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r) * (trans_res_S_aa_I_aa_r ...
            + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r) * (trans_res_S_aa_I_s_aa_r));

        R_mono_S_i(2,1:ind-1) = [S(1:ind-1) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(gamma_I_s)*(beta_S_I_s))]';

        R_mono_S_i(2,ind:length(tspan)) = S_aa(ind:end) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
            + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa));
    end
end
if plot3 == 1
    plot(tspan,R_mono_S_r(1,:),'-','Color', [207, 207, 242]./255,'LineWidth',LW)
    hold on
    plot(tspan,R_mono_S_r(2,:),'-','Color', [209, 242, 221]./255,'LineWidth',LW)
    hold on
    % plot(tspan,R_mono_S_i(1,:),'--','LineWidth',LW)
    % hold on
    % plot(tspan,R_mono_S_i(2,:),'--','LineWidth',LW)
    % hold on
    yline(1,'LineWidth',LW)
    hold on
end

for i_parrel = 1:length(pars.ParametersRel)
    if ~strcmp(pars.ParametersRel(i_parrel),"")
        eval(strcat(pars.ParametersRel(i_parrel), "=", pars.ValuesComb(i_parrel), ";"));
    end
end

for i_par = 1:length(pars.Parameters)
    if strcmp(pars.ParameterDescriptionsComb(i_par),"")
        eval(strcat(pars.Parameters(i_par), "=", pars.ValuesComb(i_par), ";"));
        eval(strcat("par_comb(i_par)", "=", pars.ValuesComb(i_par), ";"));
    else
        eval(strcat(pars.Parameters(i_par), "=", pars.ParameterDescriptionsComb(i_par), ";"));
        eval(strcat("par_comb(i_par)", "=", pars.ParameterDescriptionsComb(i_par), ";"));
    end
end

%no vacc, comb treat, I
R(3,1) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (beta_S_I ...
    + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
    + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa)));

R(3,2) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (...
    delta_I_I_s/(Theta_aa + gamma_I_s)*(...
    Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (...
    k_aa_r*q_s / (gamma_I_s_aa_r + k_aa_rr*q_s) * (beta_S_I_s_aa_r))));

R(3,3) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (...
    delta_I_I_s/(Theta_aa + gamma_I_s)*(...
    Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (...
    k_aa_r*q_s / (gamma_I_s_aa_r + k_aa_rr*q_s) * (...
    k_aa_rr*q_s / gamma_I_s_aa_rr * beta_S_I_s_aa_rr))));

R_check(3) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (beta_S_I ...
    + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
    + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa...
    + k_aa_r*q_s / (gamma_I_s_aa_r + k_aa_rr*q_s) * (beta_S_I_s_aa_r...
    + k_aa_rr*q_s / gamma_I_s_aa_rr * beta_S_I_s_aa_rr))));

%no vacc, comb proph, I
R(5,1) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
    + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa));

R(5,2) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (...
    delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (...
    k_aa_r * q_s /(gamma_I_s_aa_r + k_aa_rr*q_s)* (beta_S_aa_I_s_aa_r))...
    + k_aa_r * q / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_aa_I_s_aa_r)));

R(5,3) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (...
    delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (...
    k_aa_r * q_s /(gamma_I_s_aa_r + k_aa_rr*q_s)* (...
    + k_aa_rr*q_s /(gamma_I_s_aa_rr) * beta_S_aa_I_s_aa_rr))...
    + k_aa_r * q / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (...
    + k_aa_rr * q_s / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)...
    + k_aa_rr * q / (gamma_I_aa_rr + delta_I_aa_rr_I_s_aa_rr) * (beta_S_aa_I_aa_rr...
    + delta_I_aa_rr_I_s_aa_rr / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)));

R_check(5) = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
    + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa...
    + k_aa_r * q_s /(gamma_I_s_aa_r + k_aa_rr*q_s)* (beta_S_aa_I_s_aa_r...
    + k_aa_rr*q_s /(gamma_I_s_aa_rr) * beta_S_aa_I_s_aa_rr))...
    + k_aa_r * q / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_aa_I_s_aa_r...
    + k_aa_rr * q_s / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)...
    + k_aa_rr * q / (gamma_I_aa_rr + delta_I_aa_rr_I_s_aa_rr) * (beta_S_aa_I_aa_rr...
    + delta_I_aa_rr_I_s_aa_rr / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)));

%no vacc, comb treat, I_r
R(7,2) = (S0+S_v0) / (delta_I_r_I_r_s + gamma_I_r) * (beta_S_I_r ...
    + delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(beta_S_I_r_s...
    + Theta_aa / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_I_s_aa_r)));

R(7,3) = (S0+S_v0) / (delta_I_r_I_r_s + gamma_I_r) * (...
    delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(...
    Theta_aa / (gamma_I_s_aa_r + k_aa_rr * q_s) * (...
    k_aa_rr*q_s / (gamma_I_s_aa_rr) * beta_S_I_s_aa_rr)));

R_check(7) = (S0+S_v0) / (delta_I_r_I_r_s + gamma_I_r) * (beta_S_I_r ...
    + delta_I_r_I_r_s/(Theta_aa + gamma_I_r_s)*(beta_S_I_r_s...
    + Theta_aa / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_I_s_aa_r...
    + k_aa_rr*q_s / (gamma_I_s_aa_rr) * beta_S_I_s_aa_rr)));

%no vacc, comb proph, I_r
R(9,2) = (S0+S_v0) / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_aa_I_s_aa_r));

R(9,3) = (S0+S_v0) / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (...
    delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (...
    k_aa_rr * q_s /(gamma_I_s_aa_rr)* (beta_S_aa_I_s_aa_rr))...
    + k_aa_rr * q / (delta_I_aa_rr_I_s_aa_rr + gamma_I_aa_rr) * (beta_S_aa_I_aa_rr...
    + delta_I_aa_rr_I_s_aa_rr / (gamma_I_s_aa_rr) * (beta_S_aa_I_s_aa_rr)));

R_check(9) = (S0+S_v0) / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + k_aa_rr * q) * (beta_S_aa_I_aa_r...
    + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + k_aa_rr * q_s) * (beta_S_aa_I_s_aa_r...
    + k_aa_rr * q_s /(gamma_I_s_aa_rr)* (beta_S_aa_I_s_aa_rr))...
    + k_aa_rr * q / (delta_I_aa_rr_I_s_aa_rr + gamma_I_aa_rr) * (beta_S_aa_I_aa_rr...
    + delta_I_aa_rr_I_s_aa_rr / (gamma_I_s_aa_rr) * (beta_S_aa_I_s_aa_rr)));

%no vacc, comb treat, I_rr
R(10,3) = (S0+S_v0) / (delta_I_rr_I_rr_s + gamma_I_rr) * (beta_S_I_rr ...
    + delta_I_rr_I_rr_s/(Theta_aa + gamma_I_rr_s)*(beta_S_I_rr_s...
    + Theta_aa / (gamma_I_s_aa_rr) * (beta_S_I_s_aa_rr)));

%no vacc, comb proph, I_rr
R(11,3) = (S0+S_v0) / (delta_I_aa_rr_I_s_aa_rr + gamma_I_aa_rr) * (beta_S_aa_I_aa_rr...
    + delta_I_aa_rr_I_s_aa_rr / (gamma_I_s_aa_rr) * (beta_S_aa_I_s_aa_rr));

if plot1 == 1
    figure(h1)
end
for i = 0:10
    denovo_res = (k_aa_r * q_s) * i;

    R_comb_k(1,i+1) = (S0+S_v0) / (delta_I_I_s + gamma_I) * (...
        delta_I_I_s/(Theta_aa + gamma_I_s)*(...
        Theta_aa / (gamma_I_s_aa + denovo_res) * (...
        denovo_res / (gamma_I_s_aa_r + denovo_res) * (...
        denovo_res / gamma_I_s_aa_rr * beta_S_I_s_aa_rr))));

    R_comb_k(2,i+1)  = (S0+S_v0) / (delta_I_aa_I_s_aa + gamma_I_aa + denovo_res/10) * (...
        delta_I_aa_I_s_aa / (gamma_I_s_aa + denovo_res) * (...
        denovo_res /(gamma_I_s_aa_r + denovo_res)* (...
        + denovo_res /(gamma_I_s_aa_rr) * beta_S_aa_I_s_aa_rr))...
        + denovo_res/10 / (delta_I_aa_r_I_s_aa_r + gamma_I_aa_r + denovo_res/10) * (...
        + delta_I_aa_r_I_s_aa_r / (gamma_I_s_aa_r + denovo_res) * (...
        + denovo_res / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)...
        + denovo_res/10 / (gamma_I_aa_rr + delta_I_aa_rr_I_s_aa_rr) * (beta_S_aa_I_aa_rr...
        + delta_I_aa_rr_I_s_aa_rr / gamma_I_s_aa_rr * beta_S_aa_I_s_aa_rr)));
end
if plot1 == 1
    plot(0:10,R_comb_k(1,:),'-','Color', [142, 142, 224]./255,'LineWidth',LW)
    hold on
    plot(0:10,R_comb_k(2,:),'-','Color', [161, 228, 186]./255,'LineWidth',LW)
    hold on
    set(gcf, 'Position',  [100, 100, 200, 150])
end
% saveas(gcf,'FigureS2A.pdf');

if plot2 == 1
    figure(h2)
end
for i = 0:10
    trans_res_S_I_rr = beta_S_I_rr * i;
    trans_res_S_I_rr_s = beta_S_I_rr_s * i;
    trans_res_S_I_s_aa_rr = beta_S_I_s_aa_rr * i;
    trans_res_S_aa_I_aa_rr = beta_S_aa_I_aa_rr * i;
    trans_res_S_aa_I_s_aa_rr = beta_S_aa_I_s_aa_rr * i;

    R_comb_b(1,i+1) = (S0+S_v0) / (delta_I_rr_I_rr_s + gamma_I_rr) * (trans_res_S_I_rr ...
        + delta_I_rr_I_rr_s/(Theta_aa + gamma_I_rr_s)*(trans_res_S_I_rr_s...
        + Theta_aa / (gamma_I_s_aa_rr) * (trans_res_S_I_s_aa_rr)));

    R_comb_b(2,i+1)  =  (S0+S_v0) / (delta_I_aa_rr_I_s_aa_rr + gamma_I_aa_rr) * (trans_res_S_aa_I_aa_rr...
        + delta_I_aa_rr_I_s_aa_rr / (gamma_I_s_aa_rr) * (trans_res_S_aa_I_s_aa_rr));
end
if plot2 == 1
    plot(0:10,R_comb_b(1,:),'-','Color', [142, 142, 224]./255,'LineWidth',LW)
    hold on
    plot(0:10,R_comb_b(2,:),'-','Color', [161, 228, 186]./255,'LineWidth',LW)
    hold on
    yline(1,'LineWidth',LW)
    set(gcf, 'Position',  [100, 100, 200, 150])
    % saveas(gcf,'FigureS2B.pdf');
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

if plot3 == 1
    figure(h3)
end
for i_scenario = [2,3]
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

    if isempty(ind) %if no detection of epidemic, no treatment, no need to rerun
        y = y1;
        t = t1;
    else
        tspan2 = 0:0.1:(max(tspan)-time_treat); %redefine time frame for evaluation (time left between treatment initiation and max(tspan))
        [t2,y2] = ode45(@(t,y) odefcn_influenza_after_Theta_pr(t,y,par_comb),tspan2,y0_2,options); %resolve ODE this time WITH treatment
        y = [y1(1:ind,:);y2(2:end,:)]; %summarize the dynamics before and after treatment
        t = [t1(1:ind);t2(2:end)+time_treat];

        %redefine the results from y1 to population names (for
        %understanding)
        for i_y = 1:size(y,2)
            eval(strcat(states0.States(i_y), "=", "y(:,i_y);"));
        end
    end

    if i_scenario == 2
        R_comb_S_r(1,:) = ([zeros(ind-1,1);S(ind:end)]) / (delta_I_rr_I_rr_s + gamma_I_rr) * (trans_res_S_I_rr ...
            + delta_I_rr_I_rr_s/(Theta_aa + gamma_I_rr_s)*(trans_res_S_I_rr_s...
            + Theta_aa / (gamma_I_s_aa_rr) * (trans_res_S_I_s_aa_rr)));

        R_comb_S_i(1,1:ind-1) = S(1:ind-1) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(gamma_I_s)*(beta_S_I_s));

        R_comb_S_i(1,ind:length(tspan)) = [S(ind:end) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(Theta_aa + gamma_I_s)*(beta_S_I_s...
            + Theta_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_I_s_aa)))]';

    elseif i_scenario == 3
        R_comb_S_r(2,:)  = S_aa  / (delta_I_aa_rr_I_s_aa_rr + gamma_I_aa_rr) * (trans_res_S_aa_I_aa_rr...
            + delta_I_aa_rr_I_s_aa_rr / (gamma_I_s_aa_rr) * (trans_res_S_aa_I_s_aa_rr));

        R_comb_S_i(2,1:ind-1) = S(1:ind-1) / (delta_I_I_s + gamma_I) * (beta_S_I ...
            + delta_I_I_s/(gamma_I_s)*(beta_S_I_s));

        R_comb_S_i(2,ind:length(tspan))  = [S_aa(ind:end) / (delta_I_aa_I_s_aa + gamma_I_aa + k_aa_r * q) * (beta_S_aa_I_aa...
            + delta_I_aa_I_s_aa / (gamma_I_s_aa + k_aa_r * q_s) * (beta_S_aa_I_s_aa))]';
    end
end
if plot3 == 1
    plot(tspan,R_comb_S_r(1,:),'-','Color', [142, 142, 224]./255,'LineWidth',LW)
    hold on
    plot(tspan,R_comb_S_r(2,:),'-','Color', [161, 228, 186]./255,'LineWidth',LW)
    hold on
    yline(1,'LineWidth',LW)
    % hold on
    % plot(tspan,R_comb_S_i(1,:),'--','Color', [142, 142, 224]./255,'LineWidth',LW)
    % hold on
    % plot(tspan,R_comb_S_i(2,:),'--','LineWidth',LW)
    % hold on
    box off
    set(gcf, 'Position',  [100, 100, 250, 150])
    % saveas(gcf,'FigureS2K.pdf');
end

cmap = [180, 180, 180;...
    243, 214, 214;...
    221, 140, 140]./255;

if plot4 == 1
    j_count = 0;
    figure
    for j = 1:size(R,1)
        for i = size(R,2):-1:1
            plot([0,sum(R(j,1:i))],[j_count,j_count],'-','Color',cmap(i,:),'Linewidth',5)
            hold on
        end
        j_count = j_count -1;
    end
    xline(1,'Color','k','LineWidth',1.5)
    box off
    yticks({})
    set(gcf, 'Position',  [100, 100, 100, 300])
    % saveas(gcf,'FigureS1G.pdf');
end

end
