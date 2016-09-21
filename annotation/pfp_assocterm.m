function [term] = pfp_assocterm(oa, list, varargin)
    %PFP_ASSOCTERM Associated term
    %
    % [term] = PFP_ASSOCTERM(oa, list);
    %
    %   Returns terms associated with a list of objects.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % oa:   The ontology annotation structure.
    %
    % [cell or char]
    % list: [cell] - A list of object IDs.
    %       [char] - A single char object ID.
    %
    % (optional) Name-value pairs
    % [logical]
    % leafonly: A toggle for returning leaf-only terms or propagated terms
    %           default: false (returning propagated terms)
    %
    % Output
    % ------
    % [struct]
    % term: An array of term structures.
    %
    % Dependency
    % ----------
    % [>] pfp_oaproj.m
    % [>] pfp_annotsuboa.m
    % [>] pfp_leafannot.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 2
        error('pfp_assocterm:InputCount', 'Expected at least 2 inputs.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);

    % list
    validateattributes(list, {'cell', 'char'}, {'nonempty'}, '', 'list', 2);
    if ischar(list) % a single object
        list = {list};
    end
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultLEAFONLY = false;
    addParameter(p, 'leafonly', defaultLEAFONLY, @(x) islogical(x));
    parse(p, varargin{:});
    % }}}

    % prepare output {{{
    oa = pfp_annotsuboa(pfp_oaproj(oa, list, 'object'));
    if p.Results.leafonly
        term = oa.ontology.term(any(pfp_leafannot(oa), 1));
    else
        term = oa.ontology.term;
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:02:06 PM E
