%CODEGENERATOR.GENMFUNFRICTION Generate M-function for joint friction
%
% cGen.genmfunfriction() generates a robot-specific M-function to compute
% joint friction.
%
% Notes::
% - Is called only if cGen has active flag genmfun
% - Access to generated function is provided via subclass of SerialLink 
%   whose class definition is stored in cGen.robjpath.
%
% Author::
%  Joern Malzahn
%  2012 RST, Technische Universitaet Dortmund, Germany.
%  http://www.rst.e-technik.tu-dortmund.de
%
% See also CodeGenerator.CodeGenerator, CodeGenerator.gengravload.

% Copyright (C) 2012-2013, by Joern Malzahn
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
%
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com
%
% The code generation module emerged during the work on a project funded by
% the German Research Foundation (DFG, BE1569/7-1). The authors gratefully 
% acknowledge the financial support.

function [ F ] = genmfunfriction( CGen )

%% Does robot class exist?
if ~exist(fullfile(CGen.robjpath,[CGen.getrobfname,'.m']),'file')
    CGen.logmsg([datestr(now),'\tCreating ',CGen.getrobfname,' m-constructor ']);
    CGen.createmconstructor;
    CGen.logmsg('\t%s\n',' done!');
end

%% Generate m-function
CGen.logmsg([datestr(now),'\tGenerating joint friction m-function']);
symname = 'friction';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    tmpStruct = load(fname);
else
    error ('genmfunfriction:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.m']);
[~,qd] = CGen.rob.gencoords;

matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
    'outputs', {'F'},...
    'vars', {'rob',[qd]});
hStruct = createHeaderStruct(CGen.rob,symname);                 % replace autogenerated function header
replaceheader(CGen,hStruct,funfilename);
CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStruct(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Joint friction for the ',rob.name,' arm.'];
hStruct.calls = {['F = ',hStruct.funName,'(rob,qd)'],...
    ['F = rob.',hStruct.funName,'(qd)']};
hStruct.detailedDescription = {['Given a full set of generalized joint velocities the function'],...
    'computes the friction forces/torques.'};
hStruct.inputs = { ['rob: robot object of ', rob.name, ' specific class'],...
                   ['qd:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     velocities', ...
                   'Angles have to be given in radians!'};
hStruct.outputs = {['F:  [',int2str(rob.n),'x1] vector of joint friction forces/torques']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn',...
    '2012 RST, Technische Universitaet Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {'gravload'};
end
