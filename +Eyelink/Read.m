function c = Read(strPathFile,varargin)

% Eyelink.Read
%
% Description: read a eyelink .asc file
%
% Syntax: c = Eyelink.Read(strPathFile,<options>)
%
% In: 
%       strPathFile - the path to an eyelink .asc file
%   <options>       
%       favor      - ('right') return the data for the given eye if it exists,
%                     otherwise return the data from the other eye
%       strict     - (false) true to raise an error if data for the eye 
%                     specified in 'favor' does not exist
%       output     - ('struct') the output format, 'cell' or 'struct'
%       start_code - ('') regular expression for trial onset codes
%       end_code   - ('') regular expression for trial off onset codes
%       path_code  - (<NONE>) the path to a text file specifying onset and
%                     offset codes. Overrides 'start_code' and 'end_code'
% Out:
%       c - a nTrialx1 cell, where each element of c is a nDataPtx2 array where
%           column 1 is X values, column 2 is Y values OR a nTrialx1 cell of
%           structs with fields [t,x,y,d] (t=time,d=pupil-diameter)
%
% ---------------------------------------------------------------------------- %
%
% Dependencies: string2array.m (/mnt/tsestorage/eric/edf2asc/string2array.m)
%
% ---------------------------------------------------------------------------- %
%
% Updated: 2013-04-23
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

% useage of function : c = Eyelink.Read(strPathFile,'path_code',strPathConfig);
% strPathFile = /mnt/tsestorage/scottie/EyeTrack/EyeLinkAnalysis/test.asc
% strPathConfig = /mnt/tsestorage/scottie/EyeTrack/EyeLinkAnalysis/codes.config

opt = ParseArgsOpt(varargin ,...
    'favor'      , 'right'  ,...
    'strict'     , false    ,...
    'output'     , 'struct' ,...
    'start_code' , ''       ,...
    'end_code'   , ''       ,...
    'path_code'  , ''        ...
    );

%check inputs
switch lower(opt.output)
    case 'cell'
        bStruct = false;
    case 'struct'
        bStruct = true;
    otherwise
        error([opt.output ' is not a valid output format, please specify ''cell'' or ''struct''']);
end

if ~ismember(lower(opt.favor),{'right','left'})
    error([opt.favor ' is not a valid eye, please specify ''left'' or ''right''']);
end

%parse the code file if given
if ~isempty(opt.path_code)
    if exist(opt.path_code,'file')~=2
        error(['file ' opt.path_code ' does not exist...']);
    end   
    
    fid     = fopen(opt.path_code); 
    strCode = fread(fid,'*char')';
    fclose(fid);
    
    re = regexp(strCode,'start[\t:; ]*(?<start_code>[^\n]+)\n.*end[\t:; ]*(?<end_code>[^\n]+)\n?','names');
    opt.start_code = re.start_code;
    opt.end_code = re.end_code;
elseif isempty(opt.start_code) || isempty(opt.end_code)
    error('You must specify either a valid code file or regular expression for start and end codes');
end

%read the data
fid = fopen(strPathFile); 
str = fread(fid,'*char')';
fclose(fid);

%remove any carrige returns
str(str==13) = '';

%get header info
re = regexp(str,'START[ \t]+\d+[ \t]+(?<eye1>[A-Z]+)\s+(?<eye2>[A-Z]+).*\n','names');

%take the requested eye if we can
if strcmpi(re.eye1,opt.favor)
    kKeep = [2,3,4];    
elseif strcmpi(re.eye2,opt.favor)
    kKeep = [5,6,7];    
elseif opt.strict    
    error(['the ''' opt.favor ''' eye was not recorded in the given file.']);
else
    fprintf('Reading data for the %s eye...\n',re.eye1);
    kKeep = [2,3,4];    
end

%capture content between onset and offset codes
strPat  = [opt.start_code '\n(?<block>.+?)\nMSG\s+[0-9]+\s+' opt.end_code];
re      = regexp(str,strPat,'names');

%reformat
re = StructArrayRestructure(re);

%read the data
c = reshape(cellfun(@ReadBlock,re.block,'UniformOutput',false),[],1);

%------------------------------------------------------------------------------%
    function c = ReadBlock(c)
    %remove lines that do not contain data
        c = regexprep(c,'[A-Z]+[^\n]+\n?','');
    %fill missing values with zeros
        c = regexprep(c,'[ \t]\.[ \t]','0');        
    %remove the odd trailing period
        c = regexprep(c,'[ \t]+\.\n?','\n');
    %convert to double    
        c = string2array(c,[],[],true);
        if bStruct
            s.t = c(:,1);
            s.x = c(:,kKeep(1));
            s.y = c(:,kKeep(2));
            s.d = c(:,kKeep(3));
            c = s;
        else
            c = c(:,[1 kKeep]);
        end
    end
%------------------------------------------------------------------------------%
end