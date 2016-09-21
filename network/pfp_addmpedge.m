function [net] = pfp_addmpedge(net, oa, term, varargin)
    %PFP_ADDMPEDGE Add mutual positive edges
    %
    % [net] = PFP_ADDMPEDGE(net, oa, term, varargin);
    %
    %   Adds mutual positive edges to a network.
    %
    % Note
    % ----
    % Genes/proteins in net.object should use the same type of ID as of
    % oa.object.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % net:  The network structure. See pfp_netbuild.m
    %
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m
    %
    % [char or struct]
    % term: The ontology term ID or term structure.
    %
    % (optional) Name-value pairs
    % [double]
    % tau:  A non-negative (base 2 log) cutoff which must be reached so as to
    %       add edges. If tau is set to a positive value, 'q' below will be
    %       shaddowed.
    %       default: 0
    %
    % [double]
    % q:    A quantile value serves for the same purpose as 'tau'.
    %       default: 0.95
    %
    % [double]
    % w:    The edge weight of newly added edges.
    %       default: 1.0
    %
    % Output
    % ------
    % [struct]
    % net:  The resulting network structure.
    %
    % Dependency
    % ----------
    % [>] pfp_netbuild.m
    %
    % See Also
    % --------
    % [>] pfp_mutualpos.m

    % check inputs {{{
    if nargin < 3
        error('pfp_addmpedge:InputCount', 'Expected at least 3 inputs.');
    end

    % net
    validateattributes(net, {'struct'}, {'nonempty'}, '', 'net', 1);

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 2);

    % term
    validateattributes(term, {'char', 'struct'}, {'nonempty'}, '', 'term', 3);
    if isstruct(term)
        term = term.id;
    end
    [found, index] = ismember(term, {oa.ontology.term.id});
    if ~found
        error('pfp_addmpedge:InputErr', 'The given term is not in the ontology.');
    end
    % }}}

    % check extra inputs {{{
    p = inputParser;

    defaultTAU = 0;
    defaultQ   = 0.95;
    defaultW   = 1.0;

    addParameter(p, 'tau', defaultTAU, @(x) validateattributes(x, {'double'}, {'>=', 0}));
    addParameter(p, 'q', defaultQ, @(x) validateattributes(x, {'double'}, {'>=', 0, '<=', 1}));
    addParameter(p, 'w', defaultW, @(x) validateattributes(x, {'double'}, {'positive'}));

    parse(p, varargin{:});
    % }}}

    % determine co-enriched terms {{{
    % If another term is "enriched" in a similar way (implied by high "mutual
    % positive") then expand the network by adding all pairwise edges over the set
    % of genes that are annotated with that term.
    mp = pfp_mutualpos(oa.annotation(:,index), oa.annotation);
    if p.Results.tau == 0
        tau = quantile(mp, p.Results.q);
    else
        tau = p.Results.tau;
    end
    tids = find(mp > tau);
    % }}}

    % add edges {{{
    % find objects that are annotated with at least one of these terms
    objs = oa.object(any(oa.annotation(:,tids)));
    [found, index] = ismember(objs, net.object);
    if any(found)
        index = index(found);
        net.ADJ(index, index) = p.Results.w;
        % clear self-loops
        for i = 1:numel(index)
            net.ADJ(index(i),index(i)) = 0;
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 02:13:41 PM E
