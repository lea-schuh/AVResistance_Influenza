function dydt = odefcn_influenza_before_Theta_pr(t,y,par)


gamma_I = par(1);
gamma_I_s = par(2);
gamma_I_s_aa = par(3);
gamma_I_r = par(4);
gamma_I_r_s = par(5);
gamma_I_s_aa_r = par(6);
gamma_I_rr = par(7);
gamma_I_rr_s = par(8);
gamma_I_s_aa_rr = par(9);
gamma_I_aa = par(10);
gamma_I_aa_r = par(11);
gamma_I_aa_rr = par(12);
gamma_I_v = par(13);
gamma_I_v_s = par(14);
gamma_I_v_s_aa = par(15);
gamma_I_v_r = par(16);
gamma_I_v_r_s = par(17);
gamma_I_v_s_aa_r = par(18);
gamma_I_v_rr = par(19);
gamma_I_v_rr_s = par(20);
gamma_I_v_s_aa_rr = par(21);
gamma_I_v_aa = par(22);
gamma_I_v_aa_r = par(23);
gamma_I_v_aa_rr = par(24);
delta_I_I_s = par(25);
delta_I_r_I_r_s = par(26);
delta_I_rr_I_rr_s = par(27);
delta_I_aa_I_s_aa = par(28);
delta_I_aa_r_I_s_aa_r = par(29);
delta_I_aa_rr_I_s_aa_rr = par(30);
delta_I_v_I_v_s = par(31);
delta_I_v_r_I_v_r_s = par(32);
delta_I_v_rr_I_v_rr_s = par(33);
delta_I_v_aa_I_v_s_aa = par(34);
delta_I_v_aa_r_I_v_s_aa_r = par(35);
delta_I_v_aa_rr_I_v_s_aa_rr = par(36);
beta_S_I = par(37);
beta_S_I_s = par(38);
beta_S_I_s_aa = par(39);
beta_S_I_r = par(40);
beta_S_I_r_s = par(41);
beta_S_I_s_aa_r = par(42);
beta_S_I_rr = par(43);
beta_S_I_rr_s = par(44);
beta_S_I_s_aa_rr = par(45);
beta_S_I_aa = par(46);
beta_S_I_aa_r = par(47);
beta_S_I_aa_rr = par(48);
beta_S_I_v = par(49);
beta_S_I_v_s = par(50);
beta_S_I_v_s_aa = par(51);
beta_S_I_v_r = par(52);
beta_S_I_v_r_s = par(53);
beta_S_I_v_s_aa_r = par(54);
beta_S_I_v_rr = par(55);
beta_S_I_v_rr_s = par(56);
beta_S_I_v_s_aa_rr = par(57);
beta_S_I_v_aa = par(58);
beta_S_I_v_aa_r = par(59);
beta_S_I_v_aa_rr = par(60);
beta_S_aa_I = par(61);
beta_S_aa_I_s = par(62);
beta_S_aa_I_s_aa = par(63);
beta_S_aa_I_r = par(64);
beta_S_aa_I_r_s = par(65);
beta_S_aa_I_s_aa_r = par(66);
beta_S_aa_I_rr = par(67);
beta_S_aa_I_rr_s = par(68);
beta_S_aa_I_s_aa_rr = par(69);
beta_S_aa_I_aa = par(70);
beta_S_aa_I_aa_r = par(71);
beta_S_aa_I_aa_rr = par(72);
beta_S_aa_I_v = par(73);
beta_S_aa_I_v_s = par(74);
beta_S_aa_I_v_s_aa = par(75);
beta_S_aa_I_v_r = par(76);
beta_S_aa_I_v_r_s = par(77);
beta_S_aa_I_v_s_aa_r = par(78);
beta_S_aa_I_v_rr = par(79);
beta_S_aa_I_v_rr_s = par(80);
beta_S_aa_I_v_s_aa_rr = par(81);
beta_S_aa_I_v_aa = par(82);
beta_S_aa_I_v_aa_r = par(83);
beta_S_aa_I_v_aa_rr = par(84);
beta_S_v_I = par(85);
beta_S_v_I_s = par(86);
beta_S_v_I_s_aa = par(87);
beta_S_v_I_r = par(88);
beta_S_v_I_r_s = par(89);
beta_S_v_I_s_aa_r = par(90);
beta_S_v_I_rr = par(91);
beta_S_v_I_rr_s = par(92);
beta_S_v_I_s_aa_rr = par(93);
beta_S_v_I_aa = par(94);
beta_S_v_I_aa_r = par(95);
beta_S_v_I_aa_rr = par(96);
beta_S_v_I_v = par(97);
beta_S_v_I_v_s = par(98);
beta_S_v_I_v_s_aa = par(99);
beta_S_v_I_v_r = par(100);
beta_S_v_I_v_r_s = par(101);
beta_S_v_I_v_s_aa_r = par(102);
beta_S_v_I_v_rr = par(103);
beta_S_v_I_v_rr_s = par(104);
beta_S_v_I_v_s_aa_rr = par(105);
beta_S_v_I_v_aa = par(106);
beta_S_v_I_v_aa_r = par(107);
beta_S_v_I_v_aa_rr = par(108);
beta_S_v_aa_I = par(109);
beta_S_v_aa_I_s = par(110);
beta_S_v_aa_I_s_aa = par(111);
beta_S_v_aa_I_r = par(112);
beta_S_v_aa_I_r_s = par(113);
beta_S_v_aa_I_s_aa_r = par(114);
beta_S_v_aa_I_rr = par(115);
beta_S_v_aa_I_rr_s = par(116);
beta_S_v_aa_I_s_aa_rr = par(117);
beta_S_v_aa_I_aa = par(118);
beta_S_v_aa_I_aa_r = par(119);
beta_S_v_aa_I_aa_rr = par(120);
beta_S_v_aa_I_v = par(121);
beta_S_v_aa_I_v_s = par(122);
beta_S_v_aa_I_v_s_aa = par(123);
beta_S_v_aa_I_v_r = par(124);
beta_S_v_aa_I_v_r_s = par(125);
beta_S_v_aa_I_v_s_aa_r = par(126);
beta_S_v_aa_I_v_rr = par(127);
beta_S_v_aa_I_v_rr_s = par(128);
beta_S_v_aa_I_v_s_aa_rr = par(129);
beta_S_v_aa_I_v_aa = par(130);
beta_S_v_aa_I_v_aa_r = par(131);
beta_S_v_aa_I_v_aa_rr = par(132);
Theta_aa = par(133);
k_aa_r = par(134);
k_aa_rr = par(135);
q = par(136);
q_s = par(137);

dydt = zeros(28,1);

%define all states
S = y(1);	        %susceptible
I = y(2);	        %subclinically and untreated infected
I_s = y(3);	        %untreated infected with clinical symptoms
I_s_aa = y(4);	    %infected with clinical symptoms and treated with antivirals (mono or combination)
I_r = y(5);	        %subclinically infected shedding resistant virus (to one antiviral)
I_r_s = y(6);	    %infected with clincial symptoms and shedding resistant virus to one antiviral
I_s_aa_r = y(7);    %infected with clincial symptoms, treated with antivirals  (mono or combination), and shedding resistant virus to one antiviral
I_rr = y(8);	    %subclinically infected shedding resistant virus to both antivirals
I_rr_s = y(9);	    %infected with clincial symptoms and shedding resistant virus to both antivirals
I_s_aa_rr = y(10);	%infected with clincial symptoms, treated with combination of antivirals, and shedding resistant virus to both antivirals
S_aa = y(11);	    %susceptible treated with prophylaxis
I_aa = y(12);	    %infected treated with prophylaxis (mono or combination)
I_aa_r = y(13);	    %infected treated with prophylaxis (mono or combination) , and shedding resistant virus (to one antiviral)
I_aa_rr = y(14);	%infected treated with prophylaxis (mono or combination) , and shedding resistant virus (to one antiviral)
S_v	= y(15);        %vaccinated susceptible
I_v	= y(16);        %vaccinated subclinically and untreated infected
I_v_s = y(17);	    %vaccinated untreated infected with clinical symptoms
I_v_s_aa = y(18);	%vaccinated infected with clinical symptoms and treated with antivirals (mono or combination)
I_v_r = y(19);	    %vaccinated subclinically infected shedding resistant virus (to one antiviral)
I_v_r_s = y(20);	%vaccinated infected with clincial symptoms and shedding resistant virus to one antiviral
I_v_s_aa_r = y(21);	%vaccinated infected with clincial symptoms, treated with antivirals  (mono or combination), and shedding resistant virus to one antiviral
I_v_rr	= y(22);    %vaccinated subclinically infected shedding resistant virus to both antivirals
I_v_rr_s = y(23);	%vaccinated infected with clincial symptoms and shedding resistant virus to both antivirals
I_v_s_aa_rr = y(24);%vaccinated infected with clincial symptoms, treated with combination of antivirals, and shedding resistant virus to both antivirals
S_v_aa = y(25);	    %vaccinated susceptible treated with prophylaxis
I_v_aa = y(26);	    %vaccinated infected treated with prophylaxis (mono or combination)
I_v_aa_r = y(27);	%vaccinated infected treated with prophylaxis (mono or combination) , and shedding resistant virus (to one antiviral)
I_v_aa_rr = y(28);	%vaccinated infected treated with prophylaxis (mono or combination) , and shedding resistant virus (to one antiviral)

Theta_aa = 0;
Theta_pr = 0;

%define dynamics
dydt(1) = -(beta_S_I*I + beta_S_I_s*I_s + beta_S_I_s_aa*I_s_aa...
    + beta_S_I_r*I_r + beta_S_I_r_s*I_r_s + beta_S_I_s_aa_r*I_s_aa_r...
    + beta_S_I_rr*I_rr + beta_S_I_rr_s*I_rr_s + beta_S_I_s_aa_rr*I_s_aa_rr...
    + beta_S_I_aa*I_aa + beta_S_I_aa_r*I_aa_r + beta_S_I_aa_rr*I_aa_rr...
    + beta_S_I_v*I_v + beta_S_I_v_s*I_v_s + beta_S_I_v_s_aa*I_v_s_aa...
    + beta_S_I_v_r*I_v_r + beta_S_I_v_r_s*I_v_r_s + beta_S_I_v_s_aa_r*I_v_s_aa_r...
    + beta_S_I_v_rr*I_v_rr + beta_S_I_v_rr_s*I_v_rr_s + beta_S_I_v_s_aa_rr*I_v_s_aa_rr...
    + beta_S_I_v_aa*I_v_aa + beta_S_I_v_aa_r*I_v_aa_r + beta_S_I_v_aa_rr*I_v_aa_rr)*S...
    - Theta_pr*S; %S
dydt(2) =  (beta_S_I*I + beta_S_I_s*I_s + beta_S_I_s_aa*I_s_aa + beta_S_I_aa*I_aa...
    + beta_S_I_v*I_v + beta_S_I_v_s*I_v_s + beta_S_I_v_s_aa*I_v_s_aa + beta_S_I_v_aa*I_v_aa)*S...
    - delta_I_I_s*I - gamma_I*I - Theta_pr*I; %I
dydt(3) =  delta_I_I_s*I - Theta_aa*I_s - gamma_I_s*I_s; %I_s
dydt(4) =  Theta_aa*I_s + delta_I_aa_I_s_aa*I_aa - k_aa_r*q_s*I_s_aa - gamma_I_s_aa*I_s_aa; %I_s_aa
dydt(5) =  (beta_S_I_r*I_r + beta_S_I_r_s*I_r_s + beta_S_I_s_aa_r*I_s_aa_r + beta_S_I_aa_r*I_aa_r...
    + beta_S_I_v_r*I_v_r + beta_S_I_v_r_s*I_v_r_s + beta_S_I_v_s_aa_r*I_v_s_aa_r + beta_S_I_v_aa_r*I_v_aa_r)*S...
    - delta_I_r_I_r_s*I_r - gamma_I_r*I_r - Theta_pr*I_r; %I_r
dydt(6) =  delta_I_r_I_r_s*I_r - Theta_aa*I_r_s - gamma_I_r_s*I_r_s; %I_r_s
dydt(7) =  Theta_aa*I_r_s + delta_I_aa_r_I_s_aa_r*I_aa_r + k_aa_r*q_s*I_s_aa...
    - k_aa_rr*q_s*I_s_aa_r - gamma_I_s_aa_r*I_s_aa_r; %I_s_aa_r
dydt(8) = (beta_S_I_rr*I_rr + beta_S_I_rr_s*I_rr_s + beta_S_I_s_aa_rr*I_s_aa_rr + beta_S_I_aa_rr*I_aa_rr...
    + beta_S_I_v_rr*I_v_rr + beta_S_I_v_rr_s*I_v_rr_s + beta_S_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_I_v_aa_rr*I_v_aa_rr)*S...
    - delta_I_rr_I_rr_s*I_rr - gamma_I_rr*I_rr - Theta_pr*I_rr; %I_rr
dydt(9) =  delta_I_rr_I_rr_s*I_rr - Theta_aa*I_rr_s - gamma_I_rr_s*I_rr_s; %I_rr_s
dydt(10) = Theta_aa*I_rr_s + delta_I_aa_rr_I_s_aa_rr*I_aa_rr + k_aa_rr*q_s*I_s_aa_r...
    - gamma_I_s_aa_rr*I_s_aa_rr; %I_s_aa_rr
dydt(11) = Theta_pr*S...
    -(beta_S_aa_I*I + beta_S_aa_I_s*I_s + beta_S_aa_I_s_aa*I_s_aa...
    + beta_S_aa_I_r*I_r + beta_S_aa_I_r_s*I_r_s + beta_S_aa_I_s_aa_r*I_s_aa_r...
    + beta_S_aa_I_rr*I_rr + beta_S_aa_I_rr_s*I_rr_s + beta_S_aa_I_s_aa_rr*I_s_aa_rr...
    + beta_S_aa_I_aa*I_aa + beta_S_aa_I_aa_r*I_aa_r + beta_S_aa_I_aa_rr*I_aa_rr...
    + beta_S_aa_I_v*I_v + beta_S_aa_I_v_s*I_v_s + beta_S_aa_I_v_s_aa*I_v_s_aa...
    + beta_S_aa_I_v_r*I_v_r + beta_S_aa_I_v_r_s*I_v_r_s + beta_S_aa_I_v_s_aa_r*I_v_s_aa_r...
    + beta_S_aa_I_v_rr*I_v_rr + beta_S_aa_I_v_rr_s*I_v_rr_s + beta_S_aa_I_v_s_aa_rr*I_v_s_aa_rr...
    + beta_S_aa_I_v_aa*I_v_aa + beta_S_aa_I_v_aa_r*I_v_aa_r + beta_S_aa_I_v_aa_rr*I_v_aa_rr)*S_aa; %S_aa
dydt(12) = (beta_S_aa_I*I + beta_S_aa_I_s*I_s + beta_S_aa_I_s_aa*I_s_aa + beta_S_aa_I_aa*I_aa...
    + beta_S_aa_I_v*I_v + beta_S_aa_I_v_s*I_v_s + beta_S_aa_I_v_s_aa*I_v_s_aa + beta_S_aa_I_v_aa*I_v_aa)*S_aa...
    + Theta_pr*I - delta_I_aa_I_s_aa*I_aa - k_aa_r*q*I_aa - gamma_I_aa*I_aa; %I_aa
dydt(13) = (beta_S_aa_I_r*I_r + beta_S_aa_I_r_s*I_r_s + beta_S_aa_I_s_aa_r*I_s_aa_r + beta_S_aa_I_aa_r*I_aa_r...
    + beta_S_aa_I_v_r*I_v_r + beta_S_aa_I_v_r_s*I_v_r_s + beta_S_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_aa_I_v_aa_r*I_v_aa_r)*S_aa...
    + k_aa_r*q*I_aa + Theta_pr*I_r - delta_I_aa_r_I_s_aa_r*I_aa_r - k_aa_rr*q*I_aa_r - gamma_I_aa_r*I_aa_r; %I_aa_r
dydt(14) = (beta_S_aa_I_rr*I_rr + beta_S_aa_I_rr_s*I_rr_s + beta_S_aa_I_s_aa_rr*I_s_aa_rr + beta_S_aa_I_aa_rr*I_aa_rr...
    + beta_S_aa_I_v_rr*I_v_rr + beta_S_aa_I_v_rr_s*I_v_rr_s + beta_S_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_aa_I_v_aa_rr*I_v_aa_rr)*S_aa...
    + k_aa_rr*q*I_aa_r + Theta_pr*I_rr - delta_I_aa_rr_I_s_aa_rr*I_aa_rr - gamma_I_aa_rr*I_aa_rr; %I_aa_rr

%vaccinated
dydt(15) = -(beta_S_v_I*I + beta_S_v_I_s*I_s + beta_S_v_I_s_aa*I_s_aa...
    + beta_S_v_I_r*I_r + beta_S_v_I_r_s*I_r_s + beta_S_v_I_s_aa_r*I_s_aa_r...
    + beta_S_v_I_rr*I_rr + beta_S_v_I_rr_s*I_rr_s + beta_S_v_I_s_aa_rr*I_s_aa_rr...
    + beta_S_v_I_aa*I_aa + beta_S_v_I_aa_r*I_aa_r + beta_S_v_I_aa_rr*I_aa_rr...
    + beta_S_v_I_v*I_v + beta_S_v_I_v_s*I_v_s + beta_S_v_I_v_s_aa*I_v_s_aa...
    + beta_S_v_I_v_r*I_v_r + beta_S_v_I_v_r_s*I_v_r_s + beta_S_v_I_v_s_aa_r*I_v_s_aa_r...
    + beta_S_v_I_v_rr*I_v_rr + beta_S_v_I_v_rr_s*I_v_rr_s + beta_S_v_I_v_s_aa_rr*I_v_s_aa_rr...
    + beta_S_v_I_v_aa*I_v_aa + beta_S_v_I_v_aa_r*I_v_aa_r + beta_S_v_I_v_aa_rr*I_v_aa_rr)*S_v...
    - Theta_pr*S_v; %S_v
dydt(16) = (beta_S_v_I*I + beta_S_v_I_s*I_s + beta_S_v_I_s_aa*I_s_aa + beta_S_v_I_aa*I_aa...
    + beta_S_v_I_v*I_v + beta_S_v_I_v_s*I_v_s + beta_S_v_I_v_s_aa*I_v_s_aa + beta_S_v_I_v_aa*I_v_aa)*S_v...
    - delta_I_v_I_v_s*I_v - gamma_I_v*I_v - Theta_pr*I_v; %I_v
dydt(17) = delta_I_v_I_v_s*I_v - Theta_aa*I_v_s - gamma_I_v_s*I_v_s; %I_v_s
dydt(18) = Theta_aa*I_v_s + delta_I_v_aa_I_v_s_aa*I_v_aa - k_aa_r*q_s*I_v_s_aa - gamma_I_v_s_aa*I_v_s_aa; %I_v_s_aa
dydt(19) = (beta_S_v_I_r*I_r + beta_S_v_I_r_s*I_r_s + beta_S_v_I_s_aa_r*I_s_aa_r + beta_S_v_I_aa_r*I_aa_r...
    + beta_S_v_I_v_r*I_v_r + beta_S_v_I_v_r_s*I_v_r_s + beta_S_v_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_I_v_aa_r*I_v_aa_r)*S_v...
    - delta_I_v_r_I_v_r_s*I_v_r - gamma_I_v_r*I_v_r - Theta_pr*I_v_r; %I_v_r
dydt(20) = delta_I_v_r_I_v_r_s*I_v_r - Theta_aa*I_v_r_s - gamma_I_v_r_s*I_v_r_s; %I_v_r_s
dydt(21) = Theta_aa*I_v_r_s + delta_I_v_aa_r_I_v_s_aa_r*I_v_aa_r + k_aa_r*q_s*I_v_s_aa...
    - k_aa_rr*q_s*I_v_s_aa_r - gamma_I_v_s_aa_r*I_v_s_aa_r; %I_v_s_aa_r
dydt(22) = (beta_S_v_I_rr*I_rr + beta_S_v_I_rr_s*I_rr_s + beta_S_v_I_s_aa_rr*I_s_aa_rr + beta_S_v_I_aa_rr*I_aa_rr...
    + beta_S_v_I_v_rr*I_v_rr + beta_S_v_I_v_rr_s*I_v_rr_s + beta_S_v_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_I_v_aa_rr*I_v_aa_rr)*S_v...
    - delta_I_v_rr_I_v_rr_s*I_v_rr - gamma_I_v_rr*I_v_rr - Theta_pr*I_v_rr; %I_v_rr
dydt(23) = delta_I_v_rr_I_v_rr_s*I_v_rr - Theta_aa*I_v_rr_s - gamma_I_v_rr_s*I_v_rr_s; %I_v_rr_s
dydt(24) = Theta_aa*I_v_rr_s + delta_I_v_aa_rr_I_v_s_aa_rr*I_v_aa_rr + k_aa_rr*q_s*I_v_s_aa_r...
    - gamma_I_v_s_aa_rr*I_v_s_aa_rr;%I_v_s_aa_rr
dydt(25) = Theta_pr*S_v...
    -(beta_S_v_aa_I*I + beta_S_v_aa_I_s*I_s + beta_S_v_aa_I_s_aa*I_s_aa...
    + beta_S_v_aa_I_r*I_r + beta_S_v_aa_I_r_s*I_r_s + beta_S_v_aa_I_s_aa_r*I_s_aa_r...
    + beta_S_v_aa_I_rr*I_rr + beta_S_v_aa_I_rr_s*I_rr_s + beta_S_v_aa_I_s_aa_rr*I_s_aa_rr...
    + beta_S_v_aa_I_aa*I_aa + beta_S_v_aa_I_aa_r*I_aa_r + beta_S_v_aa_I_aa_rr*I_aa_rr...
    + beta_S_v_aa_I_v*I_v + beta_S_v_aa_I_v_s*I_v_s + beta_S_v_aa_I_v_s_aa*I_v_s_aa...
    + beta_S_v_aa_I_v_r*I_v_r + beta_S_v_aa_I_v_r_s*I_v_r_s + beta_S_v_aa_I_v_s_aa_r*I_v_s_aa_r...
    + beta_S_v_aa_I_v_rr*I_v_rr + beta_S_v_aa_I_v_rr_s*I_v_rr_s + beta_S_v_aa_I_v_s_aa_rr*I_v_s_aa_rr...
    + beta_S_v_aa_I_v_aa*I_v_aa + beta_S_v_aa_I_v_aa_r*I_v_aa_r + beta_S_v_aa_I_v_aa_rr*I_v_aa_rr)*S_v_aa; %S_v_aa
dydt(26) = (beta_S_v_aa_I*I + beta_S_v_aa_I_s*I_s + beta_S_v_aa_I_s_aa*I_s_aa + beta_S_v_aa_I_aa*I_aa...
    + beta_S_v_aa_I_v*I_v + beta_S_v_aa_I_v_s*I_v_s + beta_S_v_aa_I_v_s_aa*I_v_s_aa + beta_S_v_aa_I_v_aa*I_v_aa)*S_v_aa...
    + Theta_pr*I_v - delta_I_v_aa_I_v_s_aa*I_v_aa - k_aa_r*q*I_v_aa - gamma_I_v_aa*I_v_aa; %I_v_aa
dydt(27) = (beta_S_v_aa_I_r*I_r + beta_S_v_aa_I_r_s*I_r_s + beta_S_v_aa_I_s_aa_r*I_s_aa_r + beta_S_v_aa_I_aa_r*I_aa_r...
    + beta_S_v_aa_I_v_r*I_v_r + beta_S_v_aa_I_v_r_s*I_v_r_s + beta_S_v_aa_I_v_s_aa_r*I_v_s_aa_r + beta_S_v_aa_I_v_aa_r*I_v_aa_r)*S_v_aa...
    + k_aa_r*q*I_v_aa + Theta_pr*I_v_r - delta_I_v_aa_r_I_v_s_aa_r*I_v_aa_r - k_aa_rr*q*I_v_aa_r - gamma_I_v_aa_r*I_v_aa_r; %I_v_aa_r
dydt(28) = (beta_S_v_aa_I_rr*I_rr + beta_S_v_aa_I_rr_s*I_rr_s + beta_S_v_aa_I_s_aa_rr*I_s_aa_rr + beta_S_v_aa_I_aa_rr*I_aa_rr...
    + beta_S_v_aa_I_v_rr*I_v_rr + beta_S_v_aa_I_v_rr_s*I_v_rr_s + beta_S_v_aa_I_v_s_aa_rr*I_v_s_aa_rr + beta_S_v_aa_I_v_aa_rr*I_v_aa_rr)*S_v_aa...
    + k_aa_rr*q*I_v_aa_r + Theta_pr*I_v_rr - delta_I_v_aa_rr_I_v_s_aa_rr*I_v_aa_rr - gamma_I_v_aa_rr*I_v_aa_rr; %I_v_aa_rr

end