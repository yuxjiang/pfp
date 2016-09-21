function [] = idmapping_build_ups(ifile, ofile)
    %IDMAPPING_BUILD_UPS ID mapping build UniProt ID, primary and secondary accession
    %
    % [] = BUILD_IDMAPPING_UACC(ifile, ofile);
    %
    %   Builds ID mapping file. 3 fields (uid, pacc, sacc)
    %
    %   uid  - UniProt ID
    %   pacc - UniProt primary accession
    %   sacc - UniProt secondary accession
    %
    % Input
    % -----
    % [char]
    % ifile:  The input file, having the format
    %         ID    <uid>    Reviewed/Unreviewed;    xxx AA.
    %         AC    <pacc>;[<sacc 1>;...;<sacc k>]
    %         [AC    <sacc k+1>;...]
    %         ...
    %         //
    %         this file can be extract from UniProtKB txt data file by
    %         egrep '^ID|^AC|^//' [txt data file] > [ifile]
    %
    % [char]
    % ofile:  The output file, having three columns: U P S
    %         <uid> <pacc> <sacc>
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 2
        error('idmapping_build_ups:InputCount', 'Expected 2 inputs.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('idmapping_build_ups:FileErr', 'Cannot open the input file.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 2);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('idmapping_build_ups:FileErr', 'Cannot open the output file.');
    end
    % }}}

    % converting {{{
    acc_pattern = '[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}';
    id_pattern  = ['([A-Z0-9]{1,5}|', acc_pattern, ')_[A-Z0-9]{1,5}'];

    tline = fgets(fin);
    while ischar(tline)
        % extract ID
        if strcmp('I', tline(1))
            id = regexp(tline, id_pattern, 'match', 'once');
        else
            error('Input file format error.');
        end
        tline = fgets(fin);

        vector = {};
        % accumulate Accession
        while ~isempty(tline) && strcmp('A', tline(1))
            extracted = regexp(tline, acc_pattern, 'match');
            vector = [vector, extracted];
            tline = fgets(fin);
        end

        if isempty(tline)
            break;
        elseif strcmp('/', tline(1)) && ~isempty(vector)
            % output
            for i = 1 : numel(vector)
                fprintf(fout, '%s\t%s\t%s\n', id, vector{1}, vector{i});
            end
        else
            error('Input file format error.');
        end
        tline = fgets(fin);
    end
    fclose(fin);
    fclose(fout);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:17:56 PM E
