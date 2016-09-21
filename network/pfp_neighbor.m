function [neighbor] = pfp_neighbor(net, obj, k)
    %PFP_NEIGHBOR neighborhood
    %
    % [neighbor] = PFP_NEIGHBOR(net, obj);
    %
    %   Returns the neighbor of a given object in the network.
    %
    % [neighbor] = PFP_NEIGHBOR(net, obj, k);
    %
    %   Returns the k-neighbor of a given object in the network.
    %
    % Input
    % -----
    % [struct]
    % net:  The network structure. See pfp_netbuild.m.
    %
    % [char]
    % obj:  Object ID.
    %
    % (optional)
    % [double]
    % k:    Specifies neighbors that are k hops away.
    %       default: 1
    %
    % Output
    % ------
    % [cell]
    % neighbor: An array of (char) object IDs.
    %
    % Dependency
    % ----------
    % [>] pfp_netbuild.m

    % check inputs {{{
    if nargin ~=2 && nargin ~= 3
        error('pfp_neighbor:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        k = 1;
    end

    % net
    validateattributes(net, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % obj
    validateattributes(obj, {'char'}, {'nonempty'}, '', 'obj', 2);
    [found, index] = ismember(obj, net.object);
    if ~found
        error('pfp_neighbor:InputErr', 'Object is not in the network.');
    end

    % k
    validateattributes(k, {'double'}, {'integer', '>=', 1}, '', '', 3);
    % }}}

    % get neighbors {{{
    A = double(net.ADJ ~= 0);
    indicator = full(A(:, index) ~= 0);
    cumA = A;
    for i = 1 : k-1
        cumA = cumA * A;
        indicator = indicator | full(cumA(:, index));
    end

    neighbor = net.object(indicator);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:15:57 PM E
