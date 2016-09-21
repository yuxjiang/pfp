function [l] = pfp_avgnodedistest(net)
    %PFP_AVGNODEDISTEST Average node distance estimate
    %
    % [l] = PFP_AVGNODEDISTEST(net);
    %
    %   Estimates the average distance between two nodes.
    %
    % Note
    % ----
    % The estimation is computed as (see Reference for details):
    %
    %      ln(N/z1)
    % l = ----------- + 1
    %      ln(z2/z1)
    %
    % where
    % z1: average number of (immediate) neighbors;
    % z2: average number of 2nd neighbors.
    %
    % Input
    % -----
    % [struct]
    % net:  The network structure. See pfp_netbuild.m.
    %
    % Output
    % ------
    % [double]
    % l:    The estimate.
    %
    % Reference
    % ---------
    % M.E.J.Newman, S.H.Strogatz and D.J.Watts, Random graphs with arbitrary
    % degree distribution and their applications, Physical Review E. Vol.64.
    % 2001
    %
    % Dependency
    % ----------
    % [>] pfp_netbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_avgnodedistest:InputCount', 'Expected 1 input.');
    end

    % net
    validateattributes(net, {'struct'}, {'nonempty'}, '', 'net', 1);
    % }}}

    % computing {{{
    A  = double(net.ADJ ~= 0);
    z1 = mean(sum(A));
    A  = (A * A) ~= 0;
    z2 = mean(sum(A));
    l  = log(numel(net.object)/z1) / log(z2/z1) + 1;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:14:10 PM E
