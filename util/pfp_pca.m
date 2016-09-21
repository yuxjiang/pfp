function [score, coeff] = pfp_pca(X, ret_var)
    %PFP_PCA Principal component analysis
    %
    % [score, coeff] = PFP_PCA(X, ret_var);
    %
    %   Does principal component analysis on the input data matrix by
    %   calculating the eigenvectors of the covariance matrix.
    %
    % Note
    % ----
    % 1. This function assumes the input X has been z-score normalized. See
    %    pfp_zscorenrm.m.
    % 2. score = X * coeff.
    % 3. This function applies 'eig' on the covariance matrix, instead of SVD
    %    decomposition of X.  See MATLAB manual page for pca() for details.
    %
    % Input
    % -----
    % (required)
    % [double]
    % X:    An n-by-p input data matrix, where
    %       n is the number of observations and
    %       p is the number of raw features.
    %
    % (optional)
    % [double]
    % ret_var:  A number within [0, 1], desired percentage of retained variance.
    %           default: 1.
    %
    % Output
    % ------
    % [double]
    % score:  An n-by-k projected resulting matrix.
    %
    % [double]
    % coeff:  A p-by-k projection matrix (coefficients).

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_pca:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        ret_var = 1.0;
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);

    % ret_var
    validateattributes(ret_var, {'double'}, {'<=', 1, '>=', 0}, '', 'ret_var', 2);
    % }}}

    % compute PCA {{{
    if ~all(abs(mean(X, 1)) < 1e-8)
        warning('pfp_pca:InputErr', 'X doesn''t have zero mean, zscore normalization is recommended.');
    end

    % take the eigenvector decomposition of the covariance matrix
    [V, D] = eig(cov(X));
    vars = diag(D);
    clear D

    total_vars = sum(vars);  % total variance

    [sorted_vars, index] = sort(vars, 'descend');

    if ret_var == 1
        picked = 1 : size(X, 2);
    else
        picked = find(cumsum(sorted_vars) / total_vars <= ret_var);
    end

    % make sure the retained variance is at least at the desired amount
    dim = min(size(X, 2), numel(picked) + 1);

    coeff = V(:, index(1:dim));
    score = X * coeff;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:35:50 PM E
