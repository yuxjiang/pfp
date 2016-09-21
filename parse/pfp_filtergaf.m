function [] = pfp_filtergaf(ifile, ofile, varargin)
    %PFP_FILTERGAF Filter GAF
    %
    % [] = PFP_FILTERGAF(ifile, ofile, NAME, VALUE);
    %
    %   Filters a file in GAF 2.0 format.
    %
    % Note
    % ----
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
    % ifile:    The GAF file needs to be filtered.
    %
    % [char]
    % ofile:    The output file name.
    %
    % (optional) Name-value pairs.
    % [char]
    % 'DB':         The database name.
    %               default: '' (do not filter)
    %
    % [char]
    % 'Qualifier':  The qualifier.
    %               'no'  - filters out all annotations with any qualifiers
    %               'bin' - filters out all annotations containing 'NOT'
    %               default: '' (do not filter)
    %
    % [cell]
    % 'Ecode':      The list of evidence code of interest.
    %               default: {'EXP','IDA','IMP','IPI','IGI','IEP','TAS','IC'}
    %
    % [char]
    % 'EcodeType':  group of evidence code, one or a collection of
    %               'expr' - experimental
    %               'comp' - computational
    %               'auth' - author statement
    %               'cura' - curator statement
    %               'auto' - automatically-assigned
    %               'obso' - obsolete
    %               default: '' (not specified)
    %
    %               See evidence code at [www.geneontology.org] for details.
    %
    % [char]
    % 'Aspect':     One of the three ontologies for GO annotation
    %               default: '' (do not filter)
    %
    % [char]
    % 'ObjType':    DB object type (e.g., 'protein').
    %               default: '' (do not filter)
    %
    % [double]
    % 'Taxon':      An array of NCBI taxon IDs to keep.
    %               default: [] (do not filter)
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin < 2
        error('pfp_filtergaf:InputCount', 'Expected >= 2 inputs.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('pfp_filtergaf:InputErr', 'Cannot open the file [%s].', ifile);
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 2);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('pfp_filtergaf:InputErr', 'Cannot open the file [%s].', ofile);
    end
    % }}}

    % parse extra arguments {{{

    % pre-defined parameters {{{
    % experimental evidence codes
    expr_codes = {'EXP', 'IDA', 'IMP', 'IPI', 'IGI', 'IEP', 'TAS', 'IC'};
    % computational analysis evidence codes
    comp_codes = {'ISS', 'ISO', 'ISA', 'ISM', 'IGC', 'IBA', 'IBD', 'IKR', 'IRD', 'RCA'};
    % author statement evidence codes
    auth_codes = {'TAS', 'NAS'};
    % curator statement codes
    cura_codes = {'IC', 'ND'};
    % automatically-assigned evidence codes
    auto_codes = {'IEA'};
    % obsolete evidence codes
    obso_codes = {'NR'};

    codebook = [expr_codes, comp_codes, auth_codes, cura_codes, auto_codes, obso_codes];
    codetype = ['expr', 'comp', 'auth', 'cura', 'auto', 'obso'];
    % }}}

    p = inputParser;
    defaultDB        = '';
    defaultQualifier = '';
    defaultECode     = [expr_codes, 'TAS', 'IC'];
    defaultECodeType = '';
    defaultAspect    = '';
    defaultObjType   = '';
    defaultTaxon     = [];

    % Due to some weirdness going on with MATLAB inputParser, the first optional
    % (key, value) pair added to the parser cannot use @ischar as a validation
    % function ...
    addParameter(p, 'ECode', defaultECode, @(x) all(ismember(x, codebook)));
    addParameter(p, 'ECodeType', defaultECodeType, @(x) all(ismember(x, codetype)));
    addParameter(p, 'DB', defaultDB, @ischar);
    addParameter(p, 'Qualifier', defaultQualifier, @ischar);
    addParameter(p, 'Aspect', defaultAspect, @(x) all(ismember(x, {'P', 'C', 'F'})));
    addParameter(p, 'ObjType', defaultObjType, @ischar);
    addParameter(p, 'Taxon', defaultTaxon, @isnumeric);

    parse(p, varargin{:});

    switch lower(p.Results.ECodeType)
        case 'comp'
            ECode = comp_codes;
        case 'expr'
            ECode = expr_codes;
        case 'auth'
            ECode = auth_codes;
        case 'cura'
            ECode = cura_codes;
        case 'auto'
            ECode = auto_codes;
        case 'obso'
            ECode = obso_codes;
        otherwise
            ECode = p.Results.ECode;
    end
    % }}}

    % filtering {{{
    block_size = 1e5;

    line_pattern = repmat('%s', 1, 17);
    data = textscan(fin, line_pattern, block_size, 'Delimiter', '\t', 'CommentStyle', '!');

    nprocessed = 0;
    out_pattern = [repmat('%s\t', 1, 16), '%s\n'];

    if ~isempty(p.Results.Taxon)
        taxon_pattern = sprintf('\\<%d\\>', p.Results.Taxon(1));
        for i = 2 : numel(p.Results.Taxon)
            taxon_pattern = sprintf('%s|\\<%d\\>', taxon_pattern, p.Results.Taxon(i));
        end
    end

    while ~isempty(data{1})
        nread = length(data{1});

        % check filters
        keep = true(nread, 1);
        if ~isempty(p.Results.DB)
            keep = keep & strcmpi(data{1}, p.Results.DB);
        end

        if ~isempty(p.Results.Qualifier)
            if strcmpi('no', p.Results.Qualifier)
                keep = keep & cellfun(@isempty, data{4});
            elseif strcmpi('bin', p.Results.Qualifier)
                % keep all entries, but treat them as binary
                keep = keep & cellfun(@isempty, regexp(data{4}, 'NOT', 'match', 'once'));
            else
                keep = keep & strcmpi(data{4}, p.Results.Qualifier);
            end
        end

        if ~isempty(p.Results.ECode)
            keep = keep & ismember(data{7}, ECode);
        end

        if ~isempty(p.Results.Aspect)
            keep = keep & ismember(data{9}, p.Results.Aspect);
        end

        if ~isempty(p.Results.ObjType)
            keep = keep & strcmpi(data{12}, p.Results.ObjType);
        end

        if ~isempty(p.Results.Taxon)
            keep = keep & ~cellfun(@isempty, regexp(data{13}, taxon_pattern, 'match', 'once'));
        end

        % remove filtered rows {{{
        data{1}(~keep)  = [];
        data{2}(~keep)  = [];
        data{3}(~keep)  = [];
        data{4}(~keep)  = [];
        data{5}(~keep)  = [];
        data{6}(~keep)  = [];
        data{7}(~keep)  = [];
        data{8}(~keep)  = [];
        data{9}(~keep)  = [];
        data{10}(~keep) = [];
        data{11}(~keep) = [];
        data{12}(~keep) = [];
        data{13}(~keep) = [];
        data{14}(~keep) = [];
        data{15}(~keep) = [];
        data{16}(~keep) = [];
        data{17}(~keep) = [];
        % }}}

        % writing out {{{
        for i = 1 : length(data{1})
            fprintf(fout, out_pattern, ...
                data{1}{i}, ...
                data{2}{i}, ...
                data{3}{i}, ...
                data{4}{i}, ...
                data{5}{i}, ...
                data{6}{i}, ...
                data{7}{i}, ...
                data{8}{i}, ...
                data{9}{i}, ...
                data{10}{i}, ...
                data{11}{i}, ...
                data{12}{i}, ...
                data{13}{i}, ...
                data{14}{i}, ...
                data{15}{i}, ...
                data{16}{i}, ...
                data{17}{i});
        end
        % }}}

        nprocessed = nprocessed + nread;
        fprintf('processed [%d] lines.\n', nprocessed);

        data = textscan(fin, line_pattern, block_size, 'Delimiter', '\t', 'CommentStyle', '!');
    end

    fclose(fin);
    fclose(fout);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:23:48 PM E
