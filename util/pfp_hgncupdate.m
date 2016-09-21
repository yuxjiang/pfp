function [hgnc] = pfp_hgncupdate(special)
    %PFP_HGNCUPDATE HGNC update
    %
    % [hgnc] = PFP_HGNCUPDATE;
    %
    %   Downloads and returns a parsed HGNC gene table structure.
    %
    % [hgnc] = PFP_HGNCUPDATE(special);
    %
    %   Returns a HGNC gene table structure with special list. See details
    %   below.
    %
    % Caveat
    % ------
    % All information are retrieved from HGNC, some id mappings could be
    % outdated. E.g., UniProt accessions.
    %
    % Input
    % -----
    % (optional)
    % [char]
    % special:  A filename of a list of special gene symbol pairs. These symbols
    %           will be forced to map to given symbols. This file must have two
    %           tab-splitted columns:
    %           <from> <to>
    %           Typically, symbols in this list appear both in HGNC "previous"
    %           and "approved" lists which leads to confusion.
    %           default: ''.
    %
    % Output
    % ------
    % [struct]
    % HGNC: A parsed HGNC structure
    %       .id         [double] HGNC ID
    %       .ensg       [cell]   Ensembl Gene ID
    %       .entrez     [double] Entrez ID
    %       .symbol     [cell]   HGNC gene approved symbol
    %       .previous
    %           .symbol [cell]   Previous approved symbol
    %           .id     [double] Current HGNC ID
    %       .synonyms
    %           .symbol [cell]   Synonyms symbol
    %           .id     [double] Current HGNC ID
    %       .special
    %           .symbol [cell]   Special symbols
    %           .id     [double] Special symbols map to these ids
    %       .name       [cell]   Gene description
    %       .uniprot    [cell]   UniProt protein (provided by EBI)
    %       .chrom      [cell]   Location of the gene on the chromosome
    %       .date       [char]   Current date.

    % check inputs {{{
    if nargin > 1
        error('pfp_:InputCount', 'Expected 0 or 1 input.');
    end

    if nargin == 0
        special = '';
    end

    % special 
    validateattributes(special, {'char'}, {}, '', 'special', 1);
    if ~isempty(special)
        % Read special symbol list if specified
        fid = fopen(special, 'r');
        if fid == -1
            error('pfp_hgncupdate:FileErr', 'Cannot open the file [%s].', special);
        end

        data = textscan(fid, '%s%s');
        [found, index] = ismember(data{2}, hgnc.symbol);
        if ~all(found)
            warning('pfp_hgncupdate:InvalidSymb', 'Some symbols are invalid.');
        end
        special.symbol = data{1}(found);
        special.id     = hgnc.id(index(found));
        fclose(fid);
    else
        special.symbol = {};
        special.id     = [];
    end
    % }}}

    % Download tsv file from HGNC {{{
    url_prefix = 'http://www.genenames.org/cgi-bin/hgnc_downloads?';
    url_col_alias     = 'col=gd_aliases';         % Synonyms
    url_col_app_sym   = 'col=gd_app_sym';         % Approved Symbol
    url_col_app_name  = 'col=gd_app_name';        % Approved Name
    url_col_hgnc_id   = 'col=gd_hgnc_id';         % HGNC ID
    url_col_prev_sym  = 'col=gd_prev_sym';        % Previous Symbols
    url_col_entrez    = 'col=gd_pub_eg_id';       % Entrez Gene ID
    url_col_ensembl   = 'col=gd_pub_ensembl_id';  % Ensembl Gene ID
    url_col_uniprot   = 'col=md_prot_id';         % UniProt accession (by EBI)
    url_col_chrom_map = 'col=gd_pub_chrom_map';   % Chromosom
    url_suffix = ['status=Approved&', ...
        'status_opt=2&', ...
        'where=&', ...
        'limit=&', ...
        'order_by=gd_hgnc_id&', ...
        'format=text&', ...
        'submit=submit'];
    url_addr = [url_prefix, ...
        url_col_hgnc_id,   '&', ...
        url_col_ensembl,   '&', ...
        url_col_entrez,    '&', ...
        url_col_app_sym,   '&', ...
        url_col_prev_sym,  '&', ...
        url_col_alias,     '&', ...
        url_col_app_name,  '&', ...
        url_col_uniprot,   '&', ...
        url_col_chrom_map, '&', ...
        url_suffix];

    raw_data = urlread(url_addr);
    % }}}

    % Parse downloaded file {{{
    pattern = '%f%s%f%s%s%s%s%s%s';
    entries = textscan(raw_data, pattern, 'Delimiter', '\t', 'headerlines', 1);

    hgnc.id     = entries{1};
    hgnc.ensg   = entries{2};
    hgnc.entrez = entries{3};
    hgnc.symbol = entries{4};

    has_prev    = ~cellfun(@isempty, entries{5});
    previous    = regexp(entries{5}, ',\s*', 'split');
    id_prev     = entries{1}(has_prev);
    symbol_prev = previous(has_prev);
    count_prev  = cellfun(@length, symbol_prev);
    id_prev     = arrayfun(@(x,l) repmat(x,l,1), id_prev, count_prev, ...
        'UniformOutput', false);
    hgnc.previous.id     = vertcat(id_prev{:});
    hgnc.previous.symbol = horzcat(symbol_prev{:})';

    has_syno    = ~cellfun(@isempty, entries{6});
    synonyms    = regexp(entries{6}, ',\s*', 'split');
    id_syno     = entries{1}(has_syno);
    symbol_syno = synonyms(has_syno);
    count_syno  = cellfun(@length, symbol_syno);
    id_syno     = arrayfun(@(x,l) repmat(x,l,1), id_syno, count_syno, ...
        'UniformOutput', false);
    hgnc.synonyms.id     = vertcat(id_syno{:});
    hgnc.synonyms.symbol = horzcat(symbol_syno{:})';
    % }}}

    % prepare for the output {{{
    hgnc.special = special;
    hgnc.name    = entries{7};
    hgnc.uniprot = entries{8};
    hgnc.chromo  = entries{9};
    hgnc.date    = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:31:04 PM E
