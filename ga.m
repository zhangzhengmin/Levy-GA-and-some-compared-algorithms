%
% Project Title: GA in MATLAB
%
% Developer: ZZM in HUST
%
% Contact Info:hust_zzm@hust.edu.cn
%

clc;
clear;
close all;

%% Problem Definition--------------------------------------------
% Problem parameters introduction and formation
[num, txt, job_info]=xlsread('..\Data\job_info 12.xls'); % the information of jobs!!!!!!
job_number=cell2mat(job_info(:,1));
machine_number=12;%please put in the machine number!!!!
for i=1:length(job_number)
    job_info{i,3}=str2num(job_info{i,3});
end
job_quantity=max(job_number);%total number of jobs
job_position=find(~isnan(job_number));
job_position=[job_position;length(job_number)+1]';
for i=1:job_quantity
    job{i}=cell2mat(job_info(job_position(i):job_position(i+1)-1,2))';
end
job_time=cell2mat(job_info(:,4))';

% GA Parameters
MaxIt = 1000;      % Maximum Number of Iterations
nPop = 100;         % Population Size
Cross_rate=0.8;           % Cross operation rate
Mutation_rate=0.3;     % Mutation operation rate

%% Initialization -------------------------------------------------
% routing allocation
population=zeros(nPop,length(job_number)*2);
for i=1:nPop
    len=length(job{1});
    for j=1:job_quantity-1
        len=len+length(job{j+1});
        Pop=zeros(1,len);
        j_pos=sort(randperm(len,length(job{j+1})));
        Pop(j_pos)=job{j+1};
        if j==1
            Pop(Pop==0)=job{j};
        else
            Pop(Pop==0)=final_pop;
        end
        final_pop=Pop;
        j=j+1;
    end
    %machine allocation
    for m=1:len
        final_pop(len+m)=job_info{m,3}(randperm(length(job_info{m,3}),1));
    end
    population(i,:)=final_pop;
    i=i+1;
end
% Objective Function
result=zeros(nPop,1);
for i=1:nPop
    x=population(i,:);
    result(i,1)=processingtime(x,job_position,machine_number,job_time);
    %complete time for each individual
end

tstart=tic;

%% GA Main Loop---------------------------------------------
for it=1:MaxIt
    
    % Select Mating Pool
    Mating_pool=mating(nPop,len,population,result);
    
    %Cross Operation
    Offspring=cross(nPop,len,job,Mating_pool,Cross_rate);
    
    %Mutation Operation
    Offspring=mutation(Offspring,nPop,len,job_info,job_position,Mutation_rate);
    
    %Calculate Processing Time
    for i=1:nPop
        x=Offspring(i,:);
        off_result(i,1)=processingtime(x,job_position,machine_number,job_time);
        %complete time for each individual
    end
    
    %Together
    result=[result;off_result];
    population=[population;Offspring];
    
    %New population
    [result,loc]=sort(result);
    result=result(1:nPop,1);
    population=population(loc(1:nPop,1),:);
    
    % Select
    best_result=min(result);
    
    % Store Record for Current Iteration
    Best(it) = best_result;
    Mean(it)=sum(result(:,1))/nPop;
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Result= ' num2str(Best(it))]);
    
    disp(['Iteration ' num2str(it) ': Mean='  num2str(Mean(it))]);
    
    tused = toc(tstart);
    if tused > 60
        break;
    end
end


%% Results----------------------------------------------

figure(1);
plot(Best, 'LineWidth', 2);
%semilogy(Best, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Result');
grid on;

figure(2);
plot(Mean, 'LineWidth', 2);
%semilogy(Best, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Mean Result');
grid on;

best=population(1,:);
gant(best,len,machine_number,best_result,job_position,job_time);