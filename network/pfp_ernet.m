function [net] = pfp_ernet(n, p)
    %PFP_ERNET Erdos-Renyi network
    %
    % [net] = PFP_ERNET(n, p);
    %
    %   Builds up an unweighted, undirected random network (Erdos-Renyi model).
    %
    % Input
    % -----
    % [double]
    % n:    The number of nodes.
    %
    % [double]
    % p:    The probability of connection between a pair of nodes.
    %
    % Output
    % ------
    % [struct]
    % net:  The random network:
    %       .object [cell]   An array of (char) object list: '1', '2', ...
    %       .ADJ    [double] A (sparse) adjacency matrix, ADJ(i, j) = 1 if node
    %                        i and node j are connected, 0 otherwise.

    % check inputs {{{
    if nargin ~= 2
        error('pfp_ernet:InputCount', 'Expected 2 inputs.');
    end

    % n
    validateattributes(n, {'double'}, {'integer', '>=', 0}, '', 'n', 1);

    % p
    validateattributes(p, {'double'}, {'real', '>=', 0, '<=', 1}, '', 'p', 2);
    % }}}

    % constructing {{{
    net.object = arrayfun(@num2str, (1 : n)', 'UniformOutput', false);
    net.ADJ = rand(n) > (1 - p);

    % clear the lower triangle
    for i = 1 : n;
        net.ADJ(i : end, i) = 0;
    end
    net.ADJ = double(sparse(net.ADJ));
    net.ADJ = net.ADJ + net.ADJ';
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:14:45 PM E
