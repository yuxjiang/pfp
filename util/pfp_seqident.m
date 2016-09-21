function [] = pfp_seqident(qseq_faa, sseq_faa, sm, ofile)
    %PFP_SEQIDENT Sequence identity
    %
    % [] = PFP_SEQIDENT(qseq_faa, sseq_faa, sm, ofile);
    %
    %   Returns the highest sequence identity (defined below) for each query
    %   sequence ('qseq_faa') against the database ('sseq_faa').
    %
    % Definition
    % ----------
    % sequence identity: (global)
    % sid = number of matched AA / max(L1, L2)
    % where L1, L2 is the length of sequence 1 and 2.
    %
    % Input
    % -----
    % [char]
    % qseq_faa: The FASTA file name of query sequences. (n sequences)
    %
    % [char]
    % sseq_faa: The FASTA file name of subject sequences. (m sequences)
    %           Note: we would assume m >> n.
    %
    % [double]
    % sm:       A 20-by-20 scoring matrix (e.g. BLOSUM62)
    %
    % [char]
    % ofile:    The output file name. Note: output format:
    %           <qseqid> <sseqid with highest sid> <corresp. sid>
    %
    % Output
    % ------
    % None.
    %
    % Dependency
    % ----------
    % [>] pfp_fastaread.m
    % [>] protglobal.m
    % [>] protglobal.cpp

    % check inputs {{{
    if nargin ~= 4
        error('pfp_seqident:InputCount', 'Expected 4 inputs.');
    end

    % check the 1st input 'qseq_faa' {{{
    validateattributes(qseq_faa, {'char'}, {}, '', 'qseq_faa', 1);
    % }}}

    % check the 2nd input 'sseq_faa' {{{
    validateattributes(sseq_faa, {'char'}, {}, '', 'sseq_faa', 1);
    % }}}

    % check the 3rd input 'sm' {{{
    validateattributes(sm, {'double'}, {'ncols', 20, 'nrows', 20}, '', 'sm', 3);
    % }}}

    % check the 4th input 'ofile' {{{
    validateattributes(ofile, {'char'}, {}, '', 'ofile', 4);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('pfp_seqident:FileErr', 'Cannot open the output file.');
    end
    % }}}
    % }}}

    % read sequences {{{
    fprintf('reading query FASTA file ... ');
    [h1, s1] = pfp_fastaread(qseq_faa);
    fprintf('done.\n');

    fprintf('reading subject FASTA file ... ');
    [h2, s2] = pfp_fastaread(sseq_faa);
    fprintf('done.\n');
    % }}}

    % check for non-AA symbol {{{
    n = numel(h1);
    m = numel(h2);

    fprintf('replacing non amino acid character(s) with ''X'' ... ');
    for i = 1 : n
        s1{i}(ismember(s1{i}, 'BJOUZ')) = 'X';
    end

    for i = 1 : m
        s2{i}(ismember(s2{i}, 'BJOUZ')) = 'X';
    end
    fprintf('done.\n');
    % }}}

    % parallel computing {{{
    p = 8;
    if isempty(gcp('nocreate'))
        parpool(p);
    end

    sseqs = loc_split_sseq(h2, s2, p);

    for i = 1 : n
        fprintf('computing [%d/%d] ... ', i, n);

        L1 = length(s1{i});
        % variables to hold result from 'p' nodes
        sid    = zeros(p, 1);
        sseqid = cell(p, 1);

        % distribute computation over nodes {{{
        parfor k = 1 : p
        for j = 1 : numel(sseqs.h{k})
            % skip subject sequences that won't give higher sid {{{
            L2 = sseqs.l{k}(j);
            if (L2 < sid(k) * L1) || (L2 > L1 / sid(k))
                % For too long or too short subject sequences, they
                % won't yield a larger sid even with a perfect match
                continue;
            end
            % }}}

            [~, sq1, sq2] = protglobal(s1{i}, sseqs.s{k}{j}, sm, -1, -11);

            s = length(find(sq1 == sq2)) / max([L1, L2]);
            if s > sid(k)
                sid(k)    = s;
                sseqid{k} = sseqs.h{k}{j};
            end
        end
    end
    % }}}

    % communicate between nodes {{{
    global_sid    = 0.0;
    global_sseqid = '';
    for k = 1 : p
        if sid(k) > global_sid
            global_sid    = sid(k);
            global_sseqid = sseqid{k};
        end
    end
    % }}}

    fprintf(fout, '%s\t%s\t%.4f\n', h1{i}, global_sseqid, global_sid);
    fprintf('done.\n');
end
fclose(fout);
% }}}
end

% function: loc_split_sseq {{{
function [sseqs] = loc_split_sseq(h, s, p)
    n = numel(h);
    sseqs.h = cell(p, 1);
    sseqs.s = cell(p, 1);
    sseqs.l = cell(p, 1);

    j = 0;
    for i = 1 : n
        j = mod(j, p) + 1;
        sseqs.h{j} = [sseqs.h{j}, h(i)];
        sseqs.s{j} = [sseqs.s{j}, s(i)];
        sseqs.l{j} = [sseqs.l{j}, length(s{i})];
    end
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:40:29 PM E
