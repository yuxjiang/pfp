function [] = pfp_convcol(ifile, col, mfile, ofile)
    %PFP_CONVCOL Convert column
    %
    % [] = PFP_CONVCOL(ifile, col, mfile, ofile);
    %
    %   Converts a column in a tab-splitted file according to a mapping table.
    %
    % Note
    % ----
    % Only entries that occurs in mfile can be mapped. A warning message will be
    % prompt if not all entries in the input file got mapped.
    %
    % Input
    % -----
    % [char]
    % ifile:    The input file name, a tab-splitted file with no header lines.
    %
    % [double]
    % col:      The column to be mapped.
    %
    % [char]
    % mfile:    The mapping file name, containing two columns with no header
    %           lines, splitted by TAB with format: <from ID> <to ID>
    %
    % [char]
    % ofile:    The output file name.
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 4
        error('pfp_convcol:InputCount', 'Expected 4 inputs.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('pfp_convcol:InputErr', 'Cannot open file [%s].', ifile);
    end

    % col
    validateattributes(col, {'double'}, {'positive', 'integer'}, '', 'col', 2);

    % mfile
    validateattributes(mfile, {'char'}, {'nonempty'}, '', 'mfile', 3);
    fmap = fopen(mfile, 'r');
    if fmap == -1
        error('pfp_convcol:InputErr', 'Cannot open file [%s].', mfile);
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 4);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('pfp_convcol:InputErr', 'Cannot open file [%s].', ofile);
    end
    % }}}

    % read 1st input line to build 'fmt' for 'textscan' {{{
    line = fgetl(fin);
    fclose(fin);
    n = numel(strsplit(line, '\t')); % number of columns in the tab-splitted file
    fin = fopen(ifile, 'r'); % re-open again
    % }}}

    % read input and mapping file {{{
    data = textscan(fin, repmat('%s', 1, n), 'Delimiter', '\t');
    mapping = textscan(fmap, '%s%s', 'Delimiter', '\t');
    fclose(fin);
    fclose(fmap);
    % }}}

    % mapping {{{
    [found, index] = ismember(data{col}, mapping{1});
    if ~all(found)
        warning('pfp_convcol:InvalidID', 'Some entries are not found in the mapping file.');
    end
    new_col = data{col};
    new_col(found) = mapping{2}(index(found));
    data{col} = new_col;
    % }}}

    % remove unmapped entries {{{
    for i = 1 : n
        data{i}(~found) = [];
    end
    % }}}

    % printing {{{
    for i = 1 : numel(data{1})
        fprintf(fout, '%s', data{1}{i});
        for j = 2 : n
            fprintf(fout, '\t%s', data{j}{i});
        end
        fprintf(fout, '\n');
    end
    fclose(fout);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:28:18 PM E
