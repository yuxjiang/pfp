function [] = pfp_uniprotkb2gaf(ifile, ofile, extract_seq)
    %PFP_UNIPROTKB2GAF UniProtKB to GAF
    %
    % [] = PFP_UNIPROTKB2GAF(ifile, ofile);
    %
    %   Parses a UniProtKB data file (especially SwissProt) and saves it as GAF
    %   2.0.
    %
    % Note
    % ----
    % 1. This function is basically used for extracting GO annotations,
    %    therefore, if an entry doesn't contain GO annotations, then it will be
    %    ignored; also, one should be aware that some columns in the resulting
    %    GAF will be empty (only starred [*] fields will be present, see below)
    %
    % 2. It is STRONGLY recommended to use 'grep' to filter out extra lines in
    %    the raw file that will not be processed by Matlab, in order to speed up
    %    the
    %    parsing. e.g.:
    %    [in bash]$ egrep '(^ID)|(^AC)|(^OX)|(^DR *GO;)|(^SQ)|(^  )|(^//)' \
    %    uniprot_sprot.dat > output
    %
    %    or further filters out IEA annotations:
    %
    %    [in bash]$ egrep '(^ID)|(^AC)|(^OX)|(^DR *GO;)|(^SQ)|(^  )|(^//)' \
    %    uniprot_sprot.dat | egrep -v '^DR.*IEA:' > output
    %
    % 3. Entries in UniProtKB dat file will be first parsed into a struct, and
    %    then output in GAF format.
    %
    % KBstruct:
    %   .id - (char) the UniprotKB ID
    %   .ac - (cell of char) UniprotKB Accession number(s)
    %   .ox - (numeric) NCBI taxon ID
    %   .dr - (n-by-3 cell of char)
    %         1st column: GO term accession
    %         2nd column: GO namespace, either of the three, F/P/C
    %         3rd column: Evidence code
    %   .sq - AA sequence
    %
    % If necessary, this struct can be extended by adding more 'cases' in the
    % 'switch' clause in the code. Also, please refer to the user manual of
    % UniprotKB for the further changes about the input data format.
    %
    % GAF format: (refer to [www.geneontology.org] for future changes)
    %   | col  |       content        | required |  card  |       example        |
    % - |  --  |          --          |    --    |   --   |          --          |
    % * | [01] |          DB          |   yes    |   1    |      UniProtKB       |
    % * |  02  |     DB_Object_ID     |   yes    |   1    |        P12345        |
    % * |  03  |   DB_Object_Symbol   |   yes    |   1    |         PHO3         |
    %   | [04] |      Qualifier       |          |  >= 0  |         NOT          |
    % * |  05  |        GO_ID         |   yes    |   1    |      GO:0003993      |
    %   |  06  |     DB:Reference     |   yes    |  >=1   |     PMID:2676709     |
    % * | [07] |    Evidence Code     |   yes    |   1    |         IMP          |
    %   |  08  |    With (or) From    |          |  >= 0  |      GO:0000346      |
    % * | [09] |        Aspect        |   yes    |   1    |          F           |
    %   |  10  |    DB_Object_Name    |          | 0 or 1 | Toll-like receptor 4 |
    % * |  11  |  DB_Object_Synonym   |          |  >= 0  |   hToll|Tollbooth    |
    %   | [12] |    DB_Object_Type    |   yes    |   1    |       protein        |
    % * | [13] |        Taxon         |   yes    | 1 or 2 |      taxon:9606      |
    %   |  14  |         Date         |   yes    |   1    |       20090118       |
    %   |  15  |     Assigned_By      |   yes    |   1    |         SGD          |
    %   |  16  | Annotation_Extension |          |  >= 0  | part_of(CL:0000576)  |
    %   |  17  | Gene_Product_From_ID |          | 0 or 1 |  UniProtKB:P12345-2  |
    % - columns with [] have filters on them.
    % - columns with * will be output.
    %
    % Input
    % -----
    % (required)
    % [char]
    % ifile:    The input data file name. Typically, uniprot_sprot.dat
    %
    % [char]
    % ofile:    The output GAF file name (extension cannot be '.fasta')
    %
    % (optional)
    % [logical]
    % extract_seq:  A boolean switch, extract sequence in FASTA or not.If yes,
    %               sequences will be output to a file with the same name as
    %               'ofile', except for the file extension to be replaced with
    %               '.fasta'.
    %               default: false
    %
    % Output
    % ------
    % None.
    %
    % Dependency
    % ----------
    % [>] pfp_fastaappend.m

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_uniprotkb2gaf:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        extract_seq = false;
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('pfp_uniprotkb2gaf:FileErr', 'Cannot open the input file.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 2);
    [ofile_p, ofile_f, ofile_e] = fileparts(ofile);
    if isempty(ofile_p)
        ofile_p = '.';
    end

    if strcmpi(ofile_e, '.fasta')
        error('pfp_uniprotkb2gaf:InputErr', 'Cannot use .fasta as GAF file extension.');
    end

    fout = fopen(ofile, 'w');
    if fout == -1
        error('pfp_uniprotkb2gaf:FileErr', 'Cannot open the output file.');
    end

    % extract_seq
    validateattributes(extract_seq, {'logical'}, {}, '', 'extract_seq', 3);
    % }}}

    % converting {{{
    % Setting up hashing parameters
    HashTable = loc_make_hashtable;

    % the regular expression of a valid UniProt Accession number
    acc_pattern = '[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}';
    id_pattern  = ['([A-Z0-9]{1,5}|', acc_pattern, ')_[A-Z0-9]{1,5}'];

    buf_size = 1e4; % buffer size for sequences
    if extract_seq
        fasta_filename = [ofile_p, '/', ofile_f, '.fasta'];
        if exist(fasta_filename, 'file')
            delete(fasta_filename);
        end
        buf_h = cell(1, buf_size); % header buffer
        buf_s = cell(1, buf_size); % sequence buffer
        n_buf = 0;
        system(['touch ', fasta_filename]);
    end

    tline = fgetl(fin);
    line_count = 1; % number of read lines

    KBstruct = struct('id', '', 'ac', [], 'ox', 0, 'dr', [], 'sq', '');

    % [LOOP] parse data file one line at a time {{{
    bs = 1e6;
    while ischar(tline)
        % display a message once every 'bs' lines {{{
        if mod(line_count, bs) == 0
            fprintf('parsed [%d] lines\n', line_count);
        end
        % }}}

        % {{{
        if ~isempty(tline)
            hash_value = HashTable(max(0, tline(1:2) - ' ') * [59; 1] + 1);
            switch hash_value
                case 01 % ID
                    KBstruct.id = regexp(tline, id_pattern, 'match', 'once');
                case 02 % AC
                    KBstruct.ac = [KBstruct.ac, regexp(tline, acc_pattern, 'match')];
                case 09 % OX
                    KBstruct.ox = cell2mat(regexp(tline, 'NCBI_TaxID=(\d+)', 'tokens', 'once'));
                case 20 % DR
                    KBstruct.dr = [KBstruct.dr; regexp(tline, 'GO;.*(GO:[0-9]{7});\s*([PFC]).*;\s*([A-Z]+):.*', 'tokens', 'once')];
                case 24 % SQ, skip
                case 25 % S2, sequence data
                    extracted = regexprep(tline, '\s', ''); % remove blanks
                    KBstruct.sq = [KBstruct.sq, extracted];
                case 26 % terminator, i.e. //
                    if ~isempty(KBstruct.dr)
                        loc_writeout_gaf(fout, KBstruct);

                        if extract_seq
                            % dump sequence to buffer
                            n_buf = n_buf + 1;
                            buf_h{n_buf} = KBstruct.ac{1};
                            buf_s{n_buf} = KBstruct.sq;

                            if n_buf >= buf_size % output if buffer is full
                                pfp_fastaappend(fasta_filename, buf_h, buf_s);
                                % flush buffer
                                buf_h = cell(1, buf_size);
                                buf_s = cell(1, buf_size);
                                n_buf = 0;
                            end
                        end
                    end
                    % refresh a new KBstruct
                    KBstruct = struct( 'id', '', 'ac', [], 'ox', 0, 'dr', [], 'sq', '');
                otherwise % 0: unknown keyword, +num: not interested
                    % do nothing for now
            end
        end
        % }}}

        tline = fgetl(fin); % read the next line
        line_count = line_count + 1;
    end
    % }}}

    % extract sequences {{{
    if extract_seq
        % output the remaining sequences in buffer
        pfp_fastaappend(fasta_filename, buf_h(1:n_buf), buf_s(1:n_buf));
        % clear buffers
        clear buf_h buf_s
    end
    % }}}

    fclose(fin);
    fclose(fout);
    % }}}
end

% function: loc_make_hashtable {{{
function [ht] = loc_make_hashtable()
    % ASCII Code for ' ': 0x20(32)
    %                '/': 0x2F(47)
    %                'A': 0x41(65)
    %                ...
    %                'Z': 0x5A(90)
    % range: 'Z' - ' ' = 58
    powers = [59; 1];
    ht = sparse(59^2, 1);
    ht(max(0, 'ID'-' ') * powers + 1) = 01; % IDentification
    ht(max(0, 'AC'-' ') * powers + 1) = 02; % ACcession number
    ht(max(0, 'DT'-' ') * powers + 1) = 03; % DaTe
    ht(max(0, 'DE'-' ') * powers + 1) = 04; % DEscription
    ht(max(0, 'GN'-' ') * powers + 1) = 05; % Gene Name
    ht(max(0, 'OS'-' ') * powers + 1) = 06; % Organism Species
    ht(max(0, 'OG'-' ') * powers + 1) = 07; % OrGanelle
    ht(max(0, 'OC'-' ') * powers + 1) = 08; % Organism Classification
    ht(max(0, 'OX'-' ') * powers + 1) = 09; % Organism taXonomy cross-reference
    ht(max(0, 'OH'-' ') * powers + 1) = 10; % Organism Host
    ht(max(0, 'RN'-' ') * powers + 1) = 11; % Reference Number
    ht(max(0, 'RP'-' ') * powers + 1) = 12; % Reference Position
    ht(max(0, 'RC'-' ') * powers + 1) = 13; % Reference Comment
    ht(max(0, 'RX'-' ') * powers + 1) = 14; % Reference cross-reference
    ht(max(0, 'RG'-' ') * powers + 1) = 15; % Reference Group
    ht(max(0, 'RA'-' ') * powers + 1) = 16; % Reference Author
    ht(max(0, 'RT'-' ') * powers + 1) = 17; % Reference Title
    ht(max(0, 'RL'-' ') * powers + 1) = 18; % Reference Location
    ht(max(0, 'CC'-' ') * powers + 1) = 19; % Comments
    ht(max(0, 'DR'-' ') * powers + 1) = 20; % Database cross-Reference
    ht(max(0, 'PE'-' ') * powers + 1) = 21; % Protein Existence
    ht(max(0, 'KW'-' ') * powers + 1) = 22; % KeyWord
    ht(max(0, 'FT'-' ') * powers + 1) = 23; % Feature Table
    ht(max(0, 'SQ'-' ') * powers + 1) = 24; % SeQuence header
    ht(max(0, '  '-' ') * powers + 1) = 25; % sequnce data
    ht(max(0, '//'-' ') * powers + 1) = 26; % terminator
end
% }}}

% function: loc_writeout_gaf {{{
% Write out a single parsed UniProtKB struct in GAF 2.0 format
function [] = loc_writeout_gaf(fid, KBstruct)
    opattern = [repmat('%s\t', 1, 16), '%s\n'];

    % form a list of secondary accession list to be column 11
    % (DB Object Synonym) of GAF 2.0
    if numel(KBstruct.ac) == 1
        secondary = '';
    else
        secondary = KBstruct.ac{2};
        for i = 3 : numel(KBstruct.ac)
            secondary = [secondary, '|', KBstruct.ac{i}];
        end
    end

    for i = 1 : size(KBstruct.dr, 1)
        fprintf(fid, opattern, ...
            'UniProtKB', ...
            KBstruct.ac{1}, ...
            KBstruct.id, ...
            '', ...
            KBstruct.dr{i,1}, ...
            '', ...
            KBstruct.dr{i,3}, ...
            '', ...
            KBstruct.dr{i,2}, ...
            '', ...
            secondary, ...
            '', ...
            KBstruct.ox, ...
            '', ...
            '', ...
            '', ...
            '');
    end
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Thu 22 Sep 2016 10:56:44 PM E
