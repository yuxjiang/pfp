function [s, f, R] = pfp_functionalflow(E, R, d)
    %PFP_FUNCTIONALFLOW Functional flow
    %
    % [s, f, R] = PFP_FUNCTIONALFLOW(E, R);
    % [s, f, R] = PFP_FUNCTIONALFLOW(E, R, d);
    %
    %   Runs the functional-flow algorithm on a (gene) network.
    %
    % Note
    % ----
    % 1. This is an implementation of the "functional flow" algorithm developed
    %    by Nabieva et al., see Reference for details.
    %
    % 2. Formula for g{t}(u, v) from page i307 was corrected as it almost
    %    certainly wasn't correct in the paper.
    %
    % Reference
    % ---------
    % Nabieva et al., Bioinformatics, 2005, 21:i302.
    %
    % Input
    % -----
    % (required)
    % [double]
    % E:  An non-negative n-by-n (weighted) adjacency matrix.
    %
    % [double]
    % R:  A 1-by-n vector of initial amount of "water" in each reservoir.
    %     'Inf' - infinity (auto refill after each iteration), known genes.
    %     '0'   - unknown genes.
    %     Note that only non-negative values are allowed.
    %
    % (optional)
    % [double]
    % d:  The number of iterations to run functional flow.
    %     default: 3
    %
    % Output
    % ------
    % [double]
    % s:  A 1-by-n score vector, which is the last row of 'f' but normalized by
    %     dividing the largest raw score. Also, scores of known genes are
    %     populated with 1.00.
    %
    % [double]
    % f:  A (d+1)-by-n matrix of received flows for each iteration and node.
    %
    % [double]
    % R:  A (d+1)-by-n matrix of the amount remained per reservoir per iteration.
    %
    % Credit
    % ------
    % Originally written by
    % Predrag Radivojac
    % Indiana University
    % Bloomingon, IN 47408
    % July 2008
    %
    % MOdified by Yuxiang Jiang

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_functionalflow:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        d = 3; % default number of iterations
    end

    % E
    validateattributes(E, {'double'}, {'square', '>=', 0}, '', 'E', 1);
    n = size(E, 1);

    % R
    validateattributes(R, {'double'}, {'vector', 'numel', n}, '', 'R', 2);
    if sum(R == 0) + sum(isinf(R)) ~= n
        error('pfp_functionalflow:InputErr', 'Only Inf and 0 are allowed for ''R''.');
    end

    % d
    validateattributes(d, {'double'}, {'positive', 'integer'}, '', 'd', 3);
    % }}}

    % functional flow {{{
    % W(i, j): normalized out-going weights
    W = bsxfun(@rdivide, E, sum(E, 2));

    tol = 1e-5;

    f = zeros(d+1, n);
    R = [reshape(R, 1, []); zeros(d, n)];
    for t = 1 : d
        fprintf('iteration: %d of %d\n', t, d);
        % g(i, j): flow i -> j
        g = min(E, bsxfun(@times, R(t,:)', W));

        % clear invalid flows, ie. reservoir low to high
        g(bsxfun(@minus, R(t,:)', R(t,:)) < tol) = 0;

        % clear flows between (Inf, Inf) reservoirs
        g(isinf(R(t,:)), isinf(R(t,:))) = 0;

        f(t+1, :) = f(t, :) + sum(g); % incoming flows only
        R(t+1, :) = R(t, :) + sum(g-g');
    end
    % }}}

    % normalization {{{
    s = f(end, :) / max(f(end, :));
    s(isinf(R(1,:))) = 1;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:49:25 PM E
