function [E, c] = pfp_oaentropy(oa)
    %PFP_OAENTROPY
    %
    %   [E, c] = PFP_OAENTROPY(oa);
    %
    %       Calculates the annotation entropy (measured in bits).
    %
    % Remarks
    % -------
    % The annotation entropy is defined as the entropy of an ontological
    % annotation (as a random variable) w.r.t. the discrete space of consistent
    % subgraphs of that ontology.
    %
    % Input
    % -----
    % [struct]
    % oa:   The ontology annotation structure, see pfp_oabuild.m
    %
    % Output
    % ------
    % [double]
    % E:    The annotation entropy.
    %
    % [double]
    % c:    The number of observed unique consistent subontologies.
    %
    % See also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_oaentropy:InputCount', 'Expected 1 input.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);
    % }}}

    % convert annotations to strings {{{
    n = numel(oa.object); % number of objects;
    astr = cell(n, 1);
    for i = 1 : n
        astr{i} = char(double(full(oa.annotation(i,:))) + '0');
        % full(oa.annotation(i,:))
    end
    % }}}

    % compute entropy {{{
    [~, ~, index] = unique(astr);
    c = max(index);
    E = 0;
    for i = 1 : max(index)
        p = sum(index==i) / n; % probability of each cdag
        E = E - (p * log2(p));
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Thu 20 Jul 2017 11:21:42 PM E
