function [] = pfp_sparsewrite(filename, X, rname, cname)
    %PFP_SPARSEWRITE
    %
    %   [] = PFP_SPARSEWRITE(filename, X);
    %
    %       Saves a sparse (double) matrix into a file.
    %
    %   [] = PFP_SPARSEWRITE(filename, X, rname, cname);
    %
    %       Saves a sparse (double) matrix into a file, but use rname and cname
    %       instead of indices.
    %
    % Note
    % ----
    % 1. If the given matrix is real-valued:
    % The sparse representation of the matrix is stored as:
    % m,n
    % row_index/name_1,col_index/name_1,value_1
    % row_index/name_2,col_index/name_2,value_2
    % ...
    % where m, n in the first line indicates the dimension of the full matrix.
    %
    % 2. If the given matrix is logical:
    % The sparse representation of the matrix is stored as:
    % m,n
    % row_index/name_1,col_index/name_1
    % row_index/name_2,col_index/name_2
    % ...
    %
    % Input
    % -----
    % (required)
    % [char]
    % filename: The output file name.
    %
    % [double/logical, sparse]
    % X:    The sparse data matrix.
    %
    % (optional)
    % [cell]
    % rname:    Row name. This function uses row index if rname is empty.
    %           default: {}
    %
    % [cell]
    % cname:    Column name. This function uses column index if cname is empty.
    %           default: {}
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 4
        error('pfp_sparsewrite:InputCount', 'Expected 2 or 4 inputs.');
    end

    if nargin == 2
        rname = {};
        cname = {};
    end
    
    % filename
    validateattributes(filename, {'char'}, {'nonempty'}, '', 'filename', 1);

    % X
    validateattributes(X, {'double', 'logical'}, {'2d'}, '', 'X', 2);

    % rname
    validateattributes(rname, {'cell'}, {'vector'}, '', 'rname', 3);
    if ~isempty(rname) && numel(rname) ~= size(X, 1)
        error('pfp_sparsewrite:InputErr', 'The number of rows doens''t equal to the number of row names.');
    end

    % cname
    validateattributes(cname, {'cell'}, {'vector'}, '', 'cname', 4);
    if ~isempty(cname) && numel(cname) ~= size(X, 2)
        error('pfp_sparsewrite:InputErr', 'The number of columns doens''t equal to the number of column names.');
    end
    % }}}

    % save {{{
    [m, n] = size(X);
    fid = fopen(filename, 'w');
    fprintf(fid, '%d,%d\n', m, n);
    if islogical(X)
        if nargin == 2
            for i = 1 : m
                for j = 1 : n
                    if X(i, j) == true
                        fprintf(fid, '%d,%d\n', i, j);
                    end
                end
            end
        else
            for i = 1 : m
                for j = 1 : n
                    if X(i, j) ~= 0
                        fprintf(fid, '%s,%s\n', rname{i}, cname{j});
                    end
                end
            end
        end
    else
        if nargin == 2
            for i = 1 : m
                for j = 1 : n
                    if X(i, j) ~= 0
                        fprintf(fid, '%d,%d,%f\n', i, j, full(X(i,j)));
                    end
                end
            end
        else
            for i = 1 : m
                for j = 1 : n
                    if X(i, j) ~= 0
                        fprintf(fid, '%s,%s,%f\n', rname{i}, cname{j}, full(X(i,j)));
                    end
                end
            end
        end
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Sun 15 Oct 2017 12:26:00 AM E
