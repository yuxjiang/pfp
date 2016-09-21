function [curve] = pfp_bacccurve(pred, ref, varargin)
    %PFP_BACCCURVE Balanced accuracy curve
    %
    % [curve] = PFP_BACCCURVE(pred, ref, varargin);
    %
    %   Returns the balanced accuracy curve(s) of predictor(s).
    %
    % Note
    % ----
    % 'curve' is function: bacc(tau).
    %
    % Input
    % -----
    % (required)
    % [double]
    % pred: An n-by-1 predicted score from the predictor. where n is the number
    %       of instances. Note that scores must be within the range [0, 1].
    %
    % [logical]
    % ref:  An n-by-1 binary vector, which is the reference.
    %
    % (optional) Name-value pairs.
    % [double]
    % tau:  A vector of k thresholds. If given an empty vector, this function
    %       uses all unique values of scores.
    %       default: []
    %
    % Output
    % ------
    % [double]
    % curve:    A k-by-2 matrix, which specifies a (tau, bacc) curve.

    % check inputs {{{
    if nargin < 2
        error('pfp_bacccurve:InputCount', 'Expected at least 2 inputs.');
    end

    % pred
    validateattributes(pred, {'double'}, {'ncols', 1, '>=', 0, '<=', 1}, '', 'pred', 1);
    n = length(pred);

    % ref
    validateattributes(ref, {'logical'}, {'ncols', 1, 'numel', n}, '', 'ref', 2);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultTAU = [];
    addParameter(p, 'tau', defaultTAU, @(x)isnumeric(x));
    parse(p, varargin{:});
    % }}}

    % calculation {{{
    if isempty(p.Results.tau)
        tau = unique(pred);
    else
        tau = p.Results.tau;
    end
    % append end-points
    tau  = unique([reshape(tau, 1, []), 0, 1+eps]);
    k    = numel(tau);
    bacc = zeros(k, 1);
    N = ~ref;
    np = sum(ref); % number of positives
    nn = sum(N);   % number of negatives
    for i = 1:k
        P = (pred>=tau(i));
        sn = sum(P&ref) / np;
        sp = sum((~P)&N) / nn;
        bacc(i) = (sn+sp) ./ 2;
    end
    curve = [reshape(tau, [], 1), bacc]
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:22:54 PM E
