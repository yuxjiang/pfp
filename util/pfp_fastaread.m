function [head, seq] = pfp_fastaread(ifile)
    %PFP_FASTAREAD FASTA read
    %
    % [head, seq] = PFP_FASTAREAD(ifile);
    %
    %   Reads sequences in FASTA format.
    %
    % Note
    % ----
    % This is a slim implementation of fastaread.m in Bioinformatics Toolbox of
    % MATLAB. One can use this slim version to avoid the issue of exceeding
    % Toolbox license limit.
    %
    % This is a straightforward implementation in that for large FASTA files it
    % might take a long time to read them in.
    %
    % Input
    % -----
    % [char]
    % ifile:    The FASTA filename.
    %
    % Output
    % ------
    % [cell]
    % head:     An array of sequence header.
    %
    % [cell]
    % seq:      An array of sequence string.
    %
    % See Also
    % --------
    % [>] pfp_fastawrite.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_fastaread:InputCount', 'Expected 1 input.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fid = fopen(ifile, 'r');
    if fid == -1
        error('pfp_fastaread:FileErr', 'Cannot open the file [%s].', ifile);
    end
    % }}}

    % read FASTA {{{
    fasta = textscan(fid, '%s', 'Whitespace', '\n');
    fasta = fasta{1};

    % remove empty lines {{{
    empty_line = cellfun(@length, fasta)==0;
    fasta(empty_line) = [];
    % }}}

    is_head = cellfun(@(x) strcmp('>', x(1)), fasta);
    index   = cumsum(is_head);

    n = max(index);
    head = cell(1, n);
    seq  = cell(1, n);
    for i = 1 : max(index)
        [head{i}, seq{i}] = loc_catseq(fasta(index == i));
    end
    fclose(fid);
    % }}}
end

% function: loc_catseq {{{
function [head, seq] = loc_catseq(chunk)
    % [head, seq] = LOC_CATSEQ(chunk);
    %
    %   Concatentates data lines for one sequence string in the first cell will be
    %   the header.
    head = chunk{1}(2:end);
    seq = regexprep(horzcat(chunk{2:end}), '\W', ''); % remove blank characters
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:29:19 PM E
