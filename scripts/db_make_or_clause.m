function res=db_make_or_clause(c,data,whichtype,eqlist)

% db_make_or_clause(c,data,whichtype)
%
% Write text string for MySQL "OR" statement.
%
% Inputs:
%  c         = column name, string
%  data      = cell array of column values
%  whichtype = 'single'
%  eqlist    = cell array of equalities, e.g. {'<','<='} etc.
%
% Returns:
%  res       = OR clause statement, text string
% 

% Created on March 18, 2010 by AB

%%
if ~exist('whichtype','var')
    whichtype='single';
end

switch whichtype 
    case 'single'
         if ~exist('eqlist','var')
            eqlist=cell(size(data));
            eqlist(:,:)={'='};
        end
        for ii=1:length(data)
            if isnumeric(data{ii}) % if data are numeric, must make strings
                if length(data{ii})>1
                    error(['ERROR DB_MAKE_OR_CLAUSE: field ' c ' has more than one data input.']);
                elseif isnan(data{ii})
                    d=[c ' IS NULL'];
                else
                    d=[c ' ' eqlist{ii} '''' num2str(data{ii}) ''''];
                end
            elseif strcmp(data{ii},'null')
                d=[c ' IS NULL'];
            else
                d=[c ' ' eqlist{ii} '''' data{ii} ''''];
            end
            if length(data)==1
                res=d;
            elseif ii==1
                res=['(' d];
            elseif ii==length(data)
                res=[res ' OR ' d ')'];
            else
                res=[res ' OR ' d];
            end
        end
end