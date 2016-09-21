function [] = pfp_saveoa(ofile, oa, varargin)
    %PFP_SAVEOA Save ontology annotation
    %
    % [] = PFP_SAVEOA(ofile, oa);
    %
    %   Outputs the ontology annotations to file in the following format:
    %   <object ID> <term ID>
    %
    % Input
    % -----
    % (required)
    % [char]
    % ofile:    The output file name.
    %
    % [struct]
    % oa:       The ontology annotation structure.
    %
    % (optional) Name-value pair
    % [cell]
    % olist:    An array of (char) object IDs.
    %           default: oa.object
    %
    % [logical]
    % leafonly: A toggle for saving leaf-only terms or propagated terms.
    %           default: false
    %
    % Output
    % ------
    % None.
    %
    % Dependency
    % ----------
    % [>] pfp_leafannot.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin < 2
        error('pfp_saveoa:InputCount', 'Expected at least 2 inputs.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('pfp_saveoa:FileErr', 'Cannot open the file [%s].', ofile);
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 2);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultOLIST    = oa.object;
    defaultLEAFONLY = false;
    addParameter(p, 'olist', defaultOLIST, @(x) all(ismember(x, oa.object)));
    addParameter(p, 'leafonly', defaultLEAFONLY, @(x) islogical(x));
    parse(p, varargin{:});
    % }}}

    % save annotations {{{
    oa = pfp_oaproj(oa, p.Results.olist, 'object');
    if p.Results.leafonly
        oa.annotation = pfp_leafannot(oa);
    end
    for i = 1 : numel(oa.object)
        tid = find(oa.annotation(i,:));
        for j = 1 : numel(tid)
            fprintf(fout, '%s\t%s\n', oa.object{i}, oa.ontology.term(tid(j)).id);
        end
    end
    fclose(fout);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:37:04 PM E
