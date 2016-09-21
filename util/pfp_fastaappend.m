function [] = pfp_fastaappend(afile, head, seq, len)
    %PFP_FASTAAPPEND FASTA dump
    %
    % [] = PFP_FASTAAPPEND(afile, head, seq);
    % [] = PFP_FASTAAPPEND(afile, head, seq, len);
    %
    %   Appends sequences in FASTA format.
    %
    % Note
    % ----
    % This function does not check the existing file. Use pfp_fastadump.m if one
    % intended to remove duplicated existing sequences.
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
    % See Also
    % --------
    % [>] pfp_fastadump.m

    % check inputs {{{
    if nargin < 3 || nargin > 4
        error('pfp_fastaappend:InputCount', 'Expected 3 or 4 inputs.');
    end

    if nargin == 3
        len = 0;
    end

    % file
    validateattributes(afile, {'char'}, {'nonempty'}, '', 'afile', 1);
    fid = fopen(ofile, 'a');
    if fid == -1
        error('pfp_fastaappend:FileErr', 'Cannot open the file [%s].', ofile);
    end

    % head
    validateattributes(head, {'cell'}, {'nonempty'}, '', 'head', 2);
    n = numel(head);

    % seq
    validateattributes(seq, {'cell'}, {'numel', n}, '', 'seq', 3);

    % len
    validateattributes(len, {'double'}, {'integer', '>=', 0}, '', '', 4);
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
% Last modified: Wed 21 Sep 2016 02:28:46 PM E
