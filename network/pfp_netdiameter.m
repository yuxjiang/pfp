function [d] = pfp_netdiameter(net)
    % PFP_NETDIAMETER Network diameter
    %
    % [d] = PFP_NETDIAMETER(net);
    %
    %   Returns the diameter of an undirected network.
    %
    % Note
    % ----
    % This function assumes that the given network is connected.
    %
    % Input
    % -----
    % [struct]
    % net:  The network structure. See pfp_netbuild.m.
    %
    % Output
    % ------
    % [double]
    % d:    The diameter.
    %
    % See Also
    % --------
    % [>] pfp_netbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_netdiameter:InputCount', 'Expected 1 input.');
    end

    % net
    validateattributes(net, {'struct'}, {'nonempty'}, '', 'net', 1);
    % }}}

    % computing {{{
    A = double(net.ADJ ~= 0);
    for i = 1 : numel(net.object)
        A(i,i) = 1;
    end
    B = A;
    d = 1;
    while ~all(all(B ~= 0))
        B = B + (B * A);
        d = d + 1
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:16:53 PM E
