function [] = pfp_fastadump(afile, head, seq, len)
    %PFP_FASTADUMP FASTA dump
    %
    % [] = PFP_FASTADUMP(afile, head, seq);
    % [] = PFP_FASTADUMP(afile, head, seq, len);
    %
    %   Dumps sequences in FASTA format, which is different from pfp_fastaappend
    %   in that duplicated sequences will be removed. While simply appending is
    %   faster.
    %
    % Note
    % ----
    % Duplicated sequences are ignored. Also, the order of sequences in the
    % resulting file is not kept.
    %
    % Input
    % -----
    % [char]
    % afile:    The FASTA filename.
    %
    % [cell]
    % head:     The sequence header.
    %
    % [cell]
    % seq:      The sequence string.
    %
    % (optional)
    % [double]
    % len:  The number of amino acids per line.
    %       default: 0 (entire sequence in one line)
    %
    % Output
    % ------
    % None.
    %
    % Dependency
    % ----------
    % [>] pfp_fastaread.m
    %
    % See Also
    % --------
    % [>] pfp_fastaappend.m

    % check inputs {{{
    if nargin < 3 || nargin > 4
        error('pfp_fastadump:InputCount', 'Expected 3 or 4 inputs.');
    end

    if nargin == 3
        len = 0;
    end

    % file
    validateattributes(afile, {'char'}, {'nonempty'}, '', 'afile', 1);

    % head
    validateattributes(head, {'cell'}, {'nonempty'}, '', 'head', 2);
    n = numel(head);

    % seq
    validateattributes(seq, {'cell'}, {'numel', n}, '', 'seq', 3);

    % len
    validateattributes(len, {'double'}, {'integer', '>=', 0}, '', '', 4);
    % }}}

    % read sequences and remove duplicates {{{
    [h, s] = pfp_fastaread(afile);
    head = [h, head];
    seq  = [s, seq];

    [head, index] = unique(head);
    seq = seq(index);

    fid = fopen(afile, 'w'); % re-open to overwrite
    % }}}

    % append sequences {{{
    for i = 1 : numel(head)
        fprintf(fid, sprintf('>%s\n', head{i}));
        if len > 0
            written  = 0;
            remained = length(seq{i});
            while remained > 0
                outlen = min(len, remained);
                fprintf(fid, '%s\n', seq{i}(written + 1 : written + outlen));
                written  = written + outlen;
                remained = remained - outlen;
            end
        else
            fprintf(fid, '%s\n', seq{i});
        end
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:29:03 PM E
