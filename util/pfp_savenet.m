function [] = pfp_savenet(ofile, net, cutoff)
    %PFP_SAVENET Save network
    %
    % [] = PFP_SAVENET(ofile, net, cutoff);
    %
    %   Write network structure to files.
    %
    % Input
    % -----
    % (required)
    % [char]
    % ofile:    The output file name.
    %
    % [struct]
    % net:      The network structure. See pfp_netbuild.m
    %
    % (optional)
    % [double]
    % cutoff:   The minimum weight to output.
    %           default: 0 (output all positive edges)
    %
    % Note
    % ----
    % tsv format: <source node> <target node> <edge weight>
    %
    % Output
    % ------
    % None.
    %
    % See Also
    % --------
    % [>] pfp_netbuild.m

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_savenet:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        cutoff = 0.0;
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fid = fopen(ofile, 'w');

    % net
    validateattributes(net, {'struct'}, {'nonempty'}, '', 'net', 2);

    % cutoff
    validateattributes(cutoff, {'double'}, {'nonempty'}, '', 'cutoff', 3);
    % }}}

    % filter edges {{{
    adj = net.ADJ;
    adj(adj < cutoff) = 0;
    % }}}

    % output {{{
    n = numel(net.object);
    for i = 1 : n
        src = net.object{i};
        index = find(full(adj(i, i+1:end) ~= 0)) + i;
        for j = 1 : numel(index)
            tgt = net.object{index(j)};
            wei = full(adj(i, index(j)));
            fprintf(fid, '%s\t%s\t%f\n', src, tgt, wei);
        end
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 02:36:30 PM E
