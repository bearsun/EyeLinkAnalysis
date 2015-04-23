function bSuccess = Convert(cPathEDF,varargin)

% Eyelink.Convert
%
% Description: convert edf files to asc
%
% Syntax: Eyelink.Convert(cPathEDF,<options>)
%
% Inputs:
%       cPathEDF - a path or cell of paths to edf files
%   <options>
%       output    - (<auto>) a path or cell of paths to output files, one for each
%                   input. if not specified input file will be renames to
%                   <input_path>.asc
%       tab_only  - (false) true to use only tabs as delimiters in the output
%                    file
%       force     - (false) true to overwrite existing output
%
% Outputs:
%       bSuccess - a logical array indicating which files were successfully
%                  converted
%
% Updated: 2013-04-23
% Scottie Alexander

opt = ParseArgsOpt(varargin,...
    'output'   , []    ,...
    'tab_only' , false ,...
    'force'    , false  ...
    );

%inputs
if ischar(cPathEDF)
    cPathEDF   = {cPathEDF};
elseif ~iscell(cPathEDF)
   error('Invalid input, first argument should be a path or cell of paths to EDF files'); 
end

%options
strOpt = conditional(opt.tab_only,' -t','');
strOpt = conditional(opt.force,[strOpt ' -y'],strOpt);

%outputs
if isempty(opt.output)
    cPathOut = strrep(cPathEDF,'.edf','.asc');
else
    if iscell(opt.output) && numel(opt.output) == numel(cPathEDF)
        cPathOut = opt.output; 
    elseif ischar(opt.output) && numel(cPathEDF) == 1
        cPathOut = {opt.output};
    else
        error('output option incorrectly specified, see ''help edf2asc'' for more info'); 
    end
end

%run it
bSuccess = cellfun(@ConvertOne,cPathEDF,cPathOut,'UniformOutput',true); 

%------------------------------------------------------------------------------%
    function b = ConvertOne(strPathEDF,strPathOut)
        if exist(strPathOut,'file') ~= 2 || opt.force
            RunBashScript([pwd '/edf2asc' strOpt ' ' strPathEDF ' ' strPathOut]);%,'silent',true);
            b = FileExists(strPathOut);
        else
            b = true;
        end
    end
%------------------------------------------------------------------------------%

end