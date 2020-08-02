function [Rank,RunTime]=WorstTechRankOpt(mInput,mOutput,iDMUo,params)
%Aim
%Estimate the worst ranking of the economic efficiency of iDMUo among DMUs (mInput,mOutput)

%inputs
%mInput: matrix of inputs, x_jm, row: DMU, column: input
%mOutput:matrix of outputs, x_jn, row: DMU, column: output
%jDMUo: a number, the DMU to be evaluated
%params: the gurobi parameters

%output
%Rank: number, the worst rank for DMUo
%RunTime: the running time (in seconds)

[J,nInput]=size(mInput);
[J1,nOutput]=size(mOutput);

BigC=0;
for m=1:nOutput
    if mOutput(iDMUo,m)~=0
        BigC=max(BigC,max(mOutput(:,m)/mOutput(iDMUo,m)));
    end
end

model.obj=[ones(J,1);zeros(nInput+nOutput,1)];
model.lb=zeros(J+nInput+nOutput,1);
model.ub=[ones(J,1);Inf*ones(nInput+nOutput,1)];
model.A=sparse([BigC*eye(J),mInput-kron(mInput(iDMUo,:),ones(J,1)),kron(mOutput(iDMUo,:),ones(J,1))-mOutput;zeros(1,J),mInput(iDMUo,:),mOutput(iDMUo,:)]);
model.rhs=[BigC*ones(J,1);1];
model.sense=[repmat('<',J,1);repmat('=',1,1)];
model.modelsense ='max';
model.vtype=[repmat('B',J,1);repmat('C',nInput+nOutput,1)]; 

results = gurobi(model,params);
RunTime=results.runtime;
Rank=results.objval;

