function varargout = ParseArgsOpt(vargin,varargin)
% ParseArgsOpt
% 
% Description:	parse a varargin cell of optional arguments and options.
%				optional arguments are arguments that do not need to be included
%				in a function call and assume a default value if omitted.
%				options are 'key'/value pairs that come at the end of a function
%				call argument list.
% 
% Syntax:	[v1,v2,...,vn,opt] = ParseArgsOpt(vargin,d1,...,dn,opt1,opt1def,...,optM,optMdef)
%
% In:
%	vargin	- the varargin cell
%	dK		- the default value of the Kth optional argument
%	optJ	- the name of the Jth option
%	optJdef	- the default value of the Jth option
% 
% Out:
%	vK			- the value of the Kth optional argument
%	opt			- a struct of option values
%
% Note:	if the user calls the function like this:
%		func(v1,...,vN-1,vN,opt1,val1,...,optM,valM), vN-1 might possibly have
%		the same value as one of the option names, and that option wasn't
%		explicitly set in the options section, then vN-1 will be confused with
%		the option.
% 
% Updated: 2012-11-04
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%number of things
	nUser		= numel(vargin);
	nDefault	= numel(varargin);
	nArgument	= nargout-1;
	nOption		= (nDefault-nArgument)/2;
%make everything happy
	varargin	= reshape(varargin,nDefault,1);
	vargin		= reshape(vargin,nUser,1);
%split the input between optional arguments and options
	%split the defaults between optional arguments and options
		defArgument	= varargin(1:nArgument);
		defOptKey	= varargin(nArgument+1:2:end);
		defOptVal	= varargin(nArgument+2:2:end);
	%split user input between optional arguments and options
		if nUser
			%find the last possibility heading backward that's a string
				for kChar=nUser-1:-2:1
					if ~ischar(vargin{kChar})
						kChar	= kChar+2;
						break;
					end
				end
			%find the user-defined options that match
				[bMatch,kDefMatch]	= ismember(vargin(kChar:2:nUser),defOptKey);
			%split
				if any(bMatch)
					kMatch	= kChar - 2 + find(bMatch)*2;
					
					userArgument	= vargin(1:min(nArgument,kMatch(1)-1));
					userOptKey		= vargin(kMatch);
					userOptVal		= vargin(kMatch+1);
				else
					userArgument			= vargin(1:min(nArgument,nUser));
					[userOptKey,userOptVal]	= deal({});
				end
		else
			varargout	= [defArgument; cell2struct(defOptVal,defOptKey)];
			
			return;
		end

%parse optional arguments
	varargout				= defArgument;
	bOmitted				= cellfun(@isempty,userArgument);
	varargout(~bOmitted)	= userArgument(~bOmitted);
%parse options
	if ~isempty(userOptKey)
		%get rid of explicitly unspecified options
			bUnspecified			= cellfun(@isempty,userOptVal);
			kDefMatch(bUnspecified)	= [];
			
			userOptKey	= userOptKey(~bUnspecified);
			userOptVal	= userOptVal(~bUnspecified);
		%get rid of duplicate options
			[userOptKey,kUnique]	= unique(userOptKey);
			userOptVal				= userOptVal(kUnique);
		%concatenate the default options with the specified options
			kDefault	= setdiff(1:nOption,kDefMatch);
			
			optKey	= [defOptKey(kDefault); userOptKey];
			optVal	= [defOptVal(kDefault); userOptVal];
	else
		optKey	= defOptKey;
		optVal	= defOptVal;
	end
	
	varargout{end+1}	= cell2struct(optVal,optKey);
