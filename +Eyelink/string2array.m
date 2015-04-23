function x = string2array(str,varargin)

% string2array
%
% Description: convert a string representing a numeric array into a double array
%              
% ***NOTE***: this is for fast, non-robust conversion ONLY (i.e. the data is
%              KNOWN to be exclusivly numeric)
%
% Syntax: string2array(str,[nl]=10,[nc]=32,[robust]=false)
%
% In: 
%       str      - a numeric array as a string
%       [nl]     - ascii value of row seperator (i.e. newline)
%       [nc]     - ascii value of column seperator (single char only), this
%                  option is ignored *IF* 'robust' is set to true
%       [robust] - robust column seperation, *IF* set to true, column seperators
%                  can be any non-newline white space character one or more
%                  times (overrides 'nc' option). MUCH slower for data with >
%                  ~10000 columns
% Out: 
%       x   - the double array
%
% Updated: 2013-04-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

[vNL,vNC,bRobust] = ParseOpts(varargin,{10,32,false});

if length(vNC) > 1
    error('column seperators can only be a single character');
end

str = strtrim(str);

bNL  = ismember(str,vNL);
nRow = sum(bNL)/length(vNL);
nRow = nRow+1;

if bRobust
    if nRow == 1
        nCol = numel(regexp(str,'[0-9\.\-e]*','match'));
    else
        nCol = numel(regexp(str(1:find(bNL,1,'first')-1),'[0-9\.\-e\+]*','match'));
    end
else
    if nRow == 1
        nCol = sum(strtrim(str)==vNC)+1;
    else
        nCol = sum(str(1:find(bNL,1,'first')-1)==vNC)+1;
    end
end

x = reshape(sscanf(str','%f'),nCol,nRow)';

%------------------------------------------------------------------------------%
    function varargout = ParseOpts(c,cDef)
        nArg = numel(cDef);
        if ~isempty(c)
            b = cellfun(@isempty,c);
        else
            b = true(nArg,1);
        end
        varargout     = cell(nArg,1);
        varargout(b)  = cDef(b);
        varargout(~b) = c(~b);
%------------------------------------------------------------------------------%
