function [ESS_estimated_schedule,Estimated_SoC,CT,DCT,K,H,Answer_all,Aineq,bineq,Aeq,beq,lowerbound,upperbound,vartype]=obtain_ESS_schedule(load_kw, battery_paramaters, opt_prmt )%
%obtain_ESS_schedule This will perform an MILP receding horizon
%optimization for the given inpt data


Final_SoC_surplus=opt_prmt(2);
Running_peak_load= opt_prmt (3);
time_slot_duration=opt_prmt(1);

Current_SoC=battery_paramaters(6);

N_time_slots=size(load_kw,1);
N_scenarios=1;

[Vars_size]= create_variable_bundle(N_time_slots);

[f]=Create_function_coefficients(N_time_slots,Vars_size);



[Aineq]=create_ineqyality_constraints(N_time_slots,N_scenarios,Vars_size,battery_paramaters);

[bineq]=create_inequality_rhs(N_time_slots,N_scenarios,battery_paramaters,load_kw,Current_SoC, Final_SoC_surplus,Running_peak_load);

[ Aeq]=create_eqyality_constraints(N_time_slots,N_scenarios,Vars_size,battery_paramaters,time_slot_duration);

[beq]= create_equality_rhs (N_time_slots,N_scenarios,battery_paramaters,load_kw,Current_SoC, Final_SoC_surplus,time_slot_duration);


[lowerbound]=create_vars_lower_bounds(N_time_slots, battery_paramaters);
[upperbound]=create_vars_upper_bounds(N_time_slots, battery_paramaters);

[vartype]=create_variables_type(N_time_slots);

ck=5;
%addpath '/research/hossein_new/CPLEX_Studio/cplex/matlab';
addpath 'D:\Program Files\IBM\ILOG\CPLEX_Studio1271\cplex\matlab\x64_win64';

[x, fval, exitflag, output] = cplexmilp (f, Aineq, bineq, Aeq, beq,[ ], [ ], [ ], lowerbound, upperbound, vartype, []);


%save 'Cplex_outputs.mat'
Answer_all=x(1:11*N_time_slots+1);
%Estimated_peak_load=x(1);
%ESS_schedule=x(2);
ESS_estimated_schedule=x(2:N_time_slots+1);

%Estimated_net_load=load_kw+x(2:N_time_slots+1);
%%% this I have to change to be generic for the stochastic case;

Estimated_SoC=x(2+4*N_time_slots: 5*N_time_slots+1);

CT=x(2+7*N_time_slots: 8*N_time_slots+1);

DCT=x(2+8*N_time_slots: 9*N_time_slots+1);

K=x(2+9*N_time_slots: 10*N_time_slots+1);
H=x(2+10*N_time_slots: 11*N_time_slots+1);

%[ Max_load(1); ESS_output; ESS_charge; ESS_discharge ; Aux1; SOC; binary_theta]


end


function [f]=Create_function_coefficients(N_time_slots,Vars_size)
%%%

Epsilon=0.001;
Epsilon2=0.03;

f_MaxLoad=  ones(  1,1);
f_ESS_usage=Epsilon* ones  (N_time_slots,1);

f_ESS_outputchange=Epsilon2* ones  (N_time_slots,1);

%%%Minimize ( Maximum load + ESS_usage )
[f]=generate_Cplx_Constraint_format( Vars_size, [1;5;8] ,f_MaxLoad,f_ESS_usage',f_ESS_outputchange');
f=f';

end



%% A_ineq


function [ A_ineq]=create_ineqyality_constraints(N_time_slots,N_scenarios,Vars_size,battery_paramaters)
%%% Ok we create the non-equality constraints block-by-sbolck
%%% The number of columns are equal to size(x)
%%% The inequalities are related to :
%%% 1) objective and auxilary vars
%%% 2) energy sufficiency   (  = sum( P <or>E) < E_max)
%%% PS_positive ---> charge
%%% 3)

% K_operation_cost=1;
% K_operation_cost2=2;
% K_Amph_to_Eenergy_upper=0.8 -  0.2 ;    %%%  SOC_{init}= 0.3 * CAPACITY
% K_Amph_to_Eenergy_lower=0.2   - 0.2 ;



[A_ineq_sec1,A_ineq_sec2,A_ineq_sec2prim]=create_Objective_aux_constraints(Vars_size,N_time_slots,N_scenarios);




[A_ineq_sec3,A_ineq_sec4]=Create_charge_dischrge_complementray_constraints(Vars_size,N_time_slots,battery_paramaters);

[A_ineq_sec5,A_ineq_sec6]=Create_charge_Discharge_Threshold_a_vector(Vars_size,N_time_slots);
% [A_ineq_sec3,A_ineq_sec4]=create_ESS_operational_constraints(Vars_size,K_Amph_to_Eenergy_upper,K_Amph_to_Eenergy_lower,Interval_duration,N_timeperiods,N_ess,N_year);
[A_ineq_sec7,A_ineq_sec8]=Create_AUX_a_vector(Vars_size,N_time_slots)

%%%%%% Final Forming of A_ineq
A_ineq=[A_ineq_sec1;A_ineq_sec2; A_ineq_sec2prim; A_ineq_sec3;A_ineq_sec4;A_ineq_sec5;A_ineq_sec6;A_ineq_sec7;A_ineq_sec8] ;
end




function [A_ineq_sec1,A_ineq_sec2,A_ineq_sec2prim]=create_Objective_aux_constraints(Vars_size,N_time_slots,N_scenarios)

%%%  sec 1&2 Convex model of Objective
%%% max (Runing_peak, Today_net_load_peak)
%%%  |X[t]|   - aux < 0

temp1=-1*ones(1,1);

temp2= eye(N_time_slots);
temp3=[];
for i=1:N_scenarios
    temp3=[temp3;temp2];
end

[A_ineq_sec1a]=generate_Cplx_Constraint_format( Vars_size, [1],temp1);

temp1=-1*ones(N_scenarios*N_time_slots,1);

[A_ineq_sec1b]=generate_Cplx_Constraint_format( Vars_size, [1;2],temp1,temp3);
A_ineq_sec1=[A_ineq_sec1a;A_ineq_sec1b];


%%%% This part below is to minimize the |x|
%%%%  We convert it into two groups of constraints
%%%%  Aux > x and  Aaux> -x
%%% in the cplex format  it will be    x- aux <0 and -x-aux <0


[A_ineq_sec2a]=generate_Cplx_Constraint_format( Vars_size, [2;5],temp2,-temp2);

[A_ineq_sec2b]=generate_Cplx_Constraint_format( Vars_size, [2;5],-temp2,-temp2);


A_ineq_sec2=[A_ineq_sec2a;A_ineq_sec2b];


temp3=eye(N_time_slots);
temp3(1,1)=0;
for i=2:N_time_slots
    temp3(i,i-1)=-1;
end


[A_ineq_sec2prima]=generate_Cplx_Constraint_format( Vars_size, [2;8],-temp3,-temp2);
[A_ineq_sec2primb]=generate_Cplx_Constraint_format( Vars_size, [2;8],temp3,-temp2);
A_ineq_sec2prim=[A_ineq_sec2prima;A_ineq_sec2primb];

end


function [A_ineq_sec3,A_ineq_sec4]=Create_charge_dischrge_complementray_constraints(Vars_size,N_time_slots,battery_paramaters)
%%%% This set of constraint is to generate the complementary condition for
%%%% charge and discharge operations ( the two inequality constraint in
%%%% equation (5) of the report)

temp2=eye(N_time_slots);
temp3=-battery_paramaters(2)*eye(N_time_slots);

[A_ineq_sec3]=generate_Cplx_Constraint_format( Vars_size, [3;7],temp2,temp3);

[A_ineq_sec4]=generate_Cplx_Constraint_format( Vars_size, [4;7],temp2,-temp3);

end

function [A_ineq_sec5,A_ineq_sec6]=Create_charge_Discharge_Threshold_a_vector(Vars_size,N_time_slots)
%%%% This set of constraint is to generate the chrge and dschrge a vector :
%%%% CT(t)-L_forecast =< X_charge & L_forecast-X(t)=<DCT(t)

temp2=eye(N_time_slots);

[A_ineq_sec5]=generate_Cplx_Constraint_format( Vars_size, [3;9],-temp2,temp2);

[A_ineq_sec6]=generate_Cplx_Constraint_format( Vars_size, [2;10],-temp2,-temp2);

end

function [A_ineq_sec7,A_ineq_sec8]=Create_AUX_a_vector(Vars_size,N_time_slots)
%%%% This set of constraint is to generate the chrge and dschrge AUX a vector :
%%%% K(t) > DCT(t) & H(t) < CT(t)

temp2=eye(N_time_slots);

[A_ineq_sec7]=generate_Cplx_Constraint_format( Vars_size, [10;11],temp2,-temp2);

[A_ineq_sec8]=generate_Cplx_Constraint_format( Vars_size, [9;12],-temp2,temp2);

end

%% b_ineq


function [b_ineq]=create_inequality_rhs(N_time_slots,N_scenarios,battery_paramaters,load_kw,Current_SoC, Final_SoC_surplus,Running_peak_load)
%%%




[b_ineq_sec1,b_ineq_sec2]=Obtain_RHS_objective_realted_terms(N_time_slots,N_scenarios,load_kw,Running_peak_load);


b_ineq_sec2prim=zeros(2*N_time_slots,1);



[b_ineq_sec3]= zeros(N_time_slots,1);
[b_ineq_sec4]=battery_paramaters(2)* ones(N_time_slots,1);


[b_ineq_sec5]=  load_kw;%is it true????
[b_ineq_sec6]= -load_kw ;%is it true????
%[b_ineq_sec5]=sum(b_ineq_sec5);
%[b_ineq_sec6]=sum(b_ineq_sec6);

[b_ineq_sec7]=zeros(N_time_slots,1);
[b_ineq_sec8]=zeros(N_time_slots,1);


b_ineq=[b_ineq_sec1;b_ineq_sec2;b_ineq_sec2prim;  b_ineq_sec3;b_ineq_sec4;b_ineq_sec5 ; b_ineq_sec6 ;b_ineq_sec7;b_ineq_sec8] ;


end


function [b_ineq_sec1,b_ineq_sec2]=Obtain_RHS_objective_realted_terms(N_time_slots,N_scenarios,load_kw,Running_peak_load)

[b_ineq_sec1a]= - Running_peak_load*ones(1,1);


temp1=reshape(load_kw,N_time_slots*N_scenarios,1);

[b_ineq_sec1b]= - temp1;

b_ineq_sec1=[b_ineq_sec1a;b_ineq_sec1b];

b_ineq_sec2=zeros(2*N_time_slots,1);




end


%% A_eq

function [ A_eq]=create_eqyality_constraints(N_time_slots,N_scenarios,Vars_size,battery_paramaters,time_slot_duration)



[A_eq_sec1]=Create_ESS_SoC_dynamic_constraints(Vars_size,N_time_slots,battery_paramaters,time_slot_duration);


[A_eq_sec2]=Create_ESS_output_constriants(Vars_size,N_time_slots);

[A_eq_sec3]=Create_ESS_horizon_end_constriants(Vars_size,N_time_slots);

A_eq= [A_eq_sec1 ;A_eq_sec2;A_eq_sec3];

end




function [A_eq_sec1]=Create_ESS_SoC_dynamic_constraints(Vars_size,N_time_slots,battery_paramaters,time_slot_duration)

temp1=eye(N_time_slots);
for i=2:N_time_slots, temp1(i,i-1)=-1; end

temp2=-time_slot_duration*battery_paramaters(3)*eye(N_time_slots);
temp3= time_slot_duration*(1/battery_paramaters(3))*eye(N_time_slots);

[A_eq_sec1]=generate_Cplx_Constraint_format( Vars_size, [3;4;6],temp2,temp3,temp1);
%[ Max_load(1); ESS_output; ESS_charge; ESS_discharge ; Aux1; SOC; binary_theta]


end

function [A_eq_sec2]=Create_ESS_output_constriants(Vars_size,N_time_slots)


temp1=eye(N_time_slots);

[A_eq_sec2]=generate_Cplx_Constraint_format( Vars_size, [2;3;4],temp1,-temp1,temp1);



end

function [A_eq_sec3]=Create_ESS_horizon_end_constriants(Vars_size,N_time_slots)

temp1= zeros(1,N_time_slots);
temp1(N_time_slots)=1;

[A_eq_sec3]=generate_Cplx_Constraint_format( Vars_size, [6],temp1);

end
%% B_eq

function [b_eq]= create_equality_rhs (N_time_slots,N_scenarios,battery_paramaters,load_kw,Current_SoC, Final_SoC_surplus,time_slot_duration)

[b_eq_sec1]= [Current_SoC; zeros(N_time_slots-1,1)];

[b_eq_sec2]= zeros(N_time_slots,1);


[b_eq_sec3]= Current_SoC+Final_SoC_surplus;

b_eq=[b_eq_sec1;b_eq_sec2;b_eq_sec3];

end


%% Vars Upper/Lower_bounds
function [lowerbound]=create_vars_lower_bounds(N_time_slots, battery_paramaters)
lowerbound_sec1=  zeros(1,1);

lowerbound_sec2= -battery_paramaters(1) * ones(N_time_slots,1);
lowerbound_sec3= 0 * ones(N_time_slots,1);
lowerbound_sec4=  0*ones(N_time_slots,1);
lowerbound_sec5=  -inf* ones(N_time_slots,1);%Z(t) which one is the correct Z(t) ? seems it defines 2 times!!
lowerbound_sec6=  battery_paramaters(5) *ones(N_time_slots,1);
lowerbound_sec7=  0 *ones(N_time_slots,1);
lowerbound_sec8=  -inf *ones(N_time_slots,1);%Z(t)
lowerbound_sec9=  -inf * ones(N_time_slots,1);% CT(t)
lowerbound_sec10= 0 *ones(N_time_slots,1);%DCT(t)
lowerbound_sec11=  -inf *ones(N_time_slots,1);%K(t)
lowerbound_sec12 = -inf *ones(N_time_slots,1);%H(t)
%%[ Max_load(1); ESS_output; ESS_charge; ESS_discharge ; Aux1; SOC; binary_theta;Z;CT;DCT;K;H]

lowerbound= [lowerbound_sec1; lowerbound_sec2;lowerbound_sec3;lowerbound_sec4;lowerbound_sec5 ;lowerbound_sec6;lowerbound_sec7;lowerbound_sec8;lowerbound_sec9;lowerbound_sec10;lowerbound_sec11;lowerbound_sec12];


end



function [upperbound]=create_vars_upper_bounds(N_time_slots, battery_paramaters)
upperbound_sec1= inf* ones(1,1);

upperbound_sec2= battery_paramaters(1) * ones(N_time_slots,1);
upperbound_sec3= battery_paramaters(1)* ones(N_time_slots,1);
upperbound_sec4= battery_paramaters(1)*ones(N_time_slots,1);
upperbound_sec5= inf*ones(N_time_slots,1);
upperbound_sec6= battery_paramaters(4)*ones(N_time_slots,1);
upperbound_sec7= 1 *ones(N_time_slots,1);
upperbound_sec8= inf *ones(N_time_slots,1);
upperbound_sec9= 0 *ones(N_time_slots,1);
upperbound_sec10= inf *ones(N_time_slots,1);
upperbound_sec11= inf *ones(N_time_slots,1);
upperbound_sec12= inf *ones(N_time_slots,1);
%%[ Max_load(1); ESS_output; ESS_charge; ESS_discharge ; Aux1; SOC; binary_theta;Z;CT;DCT;K;H]

upperbound= [upperbound_sec1; upperbound_sec2;upperbound_sec3;upperbound_sec4;upperbound_sec5 ;upperbound_sec6;upperbound_sec7;upperbound_sec8;upperbound_sec9;upperbound_sec10;upperbound_sec11;upperbound_sec12];
end



function [vartype]=create_variables_type(N_time_slots)

temp='C';
temp1='B';

vartype_sec1(1:1)= temp;
vartype_sec2(1:N_time_slots)=temp;
vartype_sec3(1:N_time_slots)=temp;
vartype_sec4(1:N_time_slots)=temp;
vartype_sec5(1:N_time_slots)=temp;
vartype_sec6(1:N_time_slots)=temp;
vartype_sec7(1:N_time_slots)=temp1;
vartype_sec8(1:N_time_slots)=temp;
vartype_sec9(1:N_time_slots)=temp;
vartype_sec10(1:N_time_slots)=temp;
vartype_sec11(1:N_time_slots)=temp;
vartype_sec12(1:N_time_slots)=temp;


vartype=[vartype_sec1,vartype_sec2,vartype_sec3,vartype_sec4,vartype_sec5,vartype_sec6,vartype_sec7,vartype_sec8,vartype_sec9,vartype_sec10,vartype_sec11,vartype_sec12];


end


%% common functions
function [Vars_size]= create_variable_bundle(N_time_slots)
%%% create and change all the variabls sizes and orders here. variable
%%% bundel is a  bundle of different set of variables such as ESS schedule, auxiliary variables, and Net load
%The input load data will have varible length. in the stochastic version it will be a matrix of load vectors in different scenarios


Vars_size=[1;N_time_slots;N_time_slots; N_time_slots;  N_time_slots; N_time_slots;  N_time_slots;N_time_slots;N_time_slots;N_time_slots;N_time_slots;N_time_slots    ];

%[ Max_load(1); ESS_output; ESS_charge; ESS_discharge ; Aux1; SOC; binary_theta;Aux2]



%Vars_size
end


function [A_block]=generate_Cplx_Constraint_format( Vars_size, Var_select,varargin)
%%% this function is supposed to create the builidng blocks of equality of
%%% non-equality constraint matrix in cplex. One first question is that
%%% should it also merge them? The constraint block could be blong to
%%% either equality matrix or inequality matrix, so I guess it  is better
%%% to keep it generic!


total_size=sum(Vars_size);

%%%find start index of each sub vector
temp1= tril(ones(numel(Vars_size),numel(Vars_size)))*Vars_size;
temp1(numel(Vars_size))=[];
Start_ind= [0;temp1]+1;

temp2=size( varargin{1} ,1);

A_block=zeros(temp2,total_size);
% A x+ By < b

for i=1: numel(Var_select),
    A_block(:,Start_ind(Var_select(i)): Start_ind(Var_select(i))+ Vars_size(Var_select(i))-1 )=varargin{i};
end



end
