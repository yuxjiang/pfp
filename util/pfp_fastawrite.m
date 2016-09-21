function [] = pfp_fastawrite(ofile, head, seq, len)
    %PFP_FASTAWRITE FASTA write
    %
    % [] = PFP_FASTAWRITE(ofile, head, seq);
    %
    %   Writes sequences in FASTA format to a file.
    %
    % [] = PFP_FASTAWRITE(ofile, head, seq, len);
    %
    %   Writes sequences in FASTA format to a file with specified number of
    %   amino acid symbols per line.
    %
    % Note
    % ----
    % This is a slim implementation of fastawrite.m in Bioinformatics Toolbox of
    % MATLAB. one can use this slim version to avoid the issue of exceeding
    % Toolbox license limit.
    %
    % This is a straightforward implementation in that for large FASTA files it
    % might take a long time to read them in.
    %
    % Duplicated sequences (same header) would be removed.
    %
    % Input
    % -----
    % [char]
    % ofile:    The FASTA filename.
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
    % See Also
    % --------
    % [>] pfp_fastaread.m

    % check inputs {{{
    if nargin < 3 || nargin > 4
        error('pfp_fastaread:InputCount', 'Expected 3 or 4 inputs.');
    end

    if nargin == 3
        len = 0;
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fid = fopen(ofile, 'w');
    if fid == -1
        error('pfp_fastawrite:FileErr', 'Cannot open the file [%s].', ofile);
    end

    % head
    validateattributes(head, {'cell'}, {'nonempty'}, '', 'head', 2);
    n = numel(head);

    % seq
    validateattributes(seq, {'cell'}, {'numel', n}, '', 'seq', 3);

    % len
    validateattributes(len, {'double'}, {'integer', '>=', 0}, '', '', 4);
    % }}}

    % remove duplicates {{{
    [head, index] = unique(head);
    seq = seq(index);
    % }}}

    % save sequences {{{
    for i = 1 : numel(head)
        fprintf(fid, sprintf('>%s\n', head{i}));
        if len > 0
            written  = 0;
            remained = length(seq{i});
            while remained > 0
                outlen = min(len, remained);
                fprintf(fid, '%s\n', seq{i}(written+1 : written+outlen));
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
%pfp_cbrewer.m Last modified: Wed 21 Sep 2016 02:29:38 PM E
