function [] = idmapping_build_pdb(ifile, ofile)
    %IDMAPPING_BUILD_PDB ID mapping build PDB
    %
    % [] = BUILD_IDMAPPING_PDB(ifile, ofile);
    %
    %   Converts PDB ID mapping file downloaded from
    %   www.uniprot.org/docs/pdbtosp.txt to a format the same as those
    %   gp2protein.* from GO ftp site.
    %
    % Input
    % -----
    % [char]
    % ifile:  The input file name (usually '/path/to/pdbtosp.txt').
    %
    % [char]
    % ofile:  The output file name.
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 2
        error('idmapping_build_pdb:InputCount', 'Expected 2 inputs.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('idmapping_build_pdb:FileErr', 'Cannot open the input file.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 2);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('idmapping_build_pdb:FileErr', 'Cannot open the output file.');
    end
    % }}}

    % converting {{{
    tline = fgets(fin);
    acc_pattern = '[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}';
    while ischar(tline)
        pdb_id = regexp(tline, '^([A-Z0-9]{4}) ', 'tokens', 'once');
        if ~isempty(pdb_id)
            acc = regexp(tline, ['\((', acc_pattern, ')\)'], 'tokens');
            if ~isempty(acc)
                fprintf(fout, 'PDB:%s\tUniProtKB:%s', pdb_id{:}, acc{1}{:});
                for i = 2 : numel(acc)
                    fprintf(fout, ';UniProtKB:%s', acc{i}{:});
                end
                fprintf(fout, '\n');
            end
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
% Last modified: Wed 21 Sep 2016 02:17:33 PM E
