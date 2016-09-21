function [p] = pfp_diffusionrank(p0, E, N, alpha, asymmetric)
    %PFP_DIFFUSIONRANK Diffusion ranking
    %
    % [p] = PFP_DIFFUSIONRANK(p0, E, N, alpha, asymmetric);
    %
    %   Runs the "diffusion kernel ranking" algorithm. See reference below for
    %   details.
    %
    % Reference
    % ---------
    % Laenen G., Thorrez L., Bornigen D. and Moreau Y., "Finding the target of a
    % drug by integration of gene expression data with a protein interaction
    % network" Mol. BioSyst. 2013
    %
    % Input
    % -----
    % (required)
    % [double]
    % p0:   The initial priorization of a list of genes, which be a row vector.
    %
    % [double]
    % E:    The weighted network, edge information.
    %
    % [double]
    % N:    The number of iterations.
    %
    % [double]
    % alpha:  The diffusion speed.
    %
    % (optional)
    % [logical]
    % asymmetric: Is the network asymmetric?
    %             default: false.
    %
    % Output
    % ------
    % [double]
    % p:  The "diffused" priorization of genes also, a row vector.

    % check inputs {{{
    if nargin ~= 4 && nargin ~= 5
        error('pfp_diffusionrank:InputCount', 'Expected 4 or 5 inputs.');
    end

    if nargin == 4
        asymmetric = false;
    end

    % p0
    validateattributes(p0, {'double'}, {'vector'}, '', 'p0', 1);
    n = numel(p0);

    % E
    validateattributes(E, {'double'}, {'ncols', n, 'nrows', n}, '', 'E', 2);

    % N
    validateattributes(N, {'double'}, {'positive', 'integer'}, '', 'N', 3);

    % alpha
    validateattributes(alpha, {'double'}, {'positive'}, '', 'alpha', 4);

    % asymmetric
    validateattributes(asymmetric, {'logical'}, {'nonempty'}, '', 'asymmetric', 5);
    % }}}

    % diffuse {{{
    L = laplacianmat(E, asymmetric);
    p0 = reshape(p0, 1, []); % make a row vector
    t = eye(size(E)) - ((alpha / N) * L);
    p = p0 * (t ^ N);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 12:41:07 PM E
