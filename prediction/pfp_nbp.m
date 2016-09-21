function [pred] = pfp_nbp(config)
    %PFP_NBP Network-based prediction
    %
    % [result] = PFP_NBP(config);
    %
    %   Runs a network based algorithm to predict protein function.
    %
    % Note
    % ----
    % 1. The prediction output will be saved to the 'output' place specified in
    %    the configuration.
    % 2. Scores are normalized to [0, 1] for convenience, do not use these raw
    %    scores as probabilities.
    %
    % Input
    % -----
    % config:   The task configuration. See pfp_nbpconf.m
    %
    % Output
    % ------
    % [struct]
    % pred:     The prediction result structure.
    %           .object   [cell]   query ID list
    %           .ontology [struct] the ontology structure
    %           .score    [double] predicted association scores
    %           .date     [char]
    %
    % Dependency
    % ----------
    % [>] pfp_annotsuboa.m
    % [>] pfp_mutualpos.m
    % [>] pfp_minmaxnrm.m
    % [>] pfp_functionalflow.m
    %
    % See Also
    % --------
    % [>] pfp_netbuild.m
    % [>] pfp_oabuild.m
    % [>] pfp_nbpconf.m
    % [>] pfp_ancestortermidx.m

    % input checking {{{
    if nargin ~= 1
        error('pfp_nbp:InputCount', 'Expected 1 input.');
    end

    % config
    validateattributes(config, {'struct'}, {'nonempty'}, '', 'config', 1);
    % }}}

    % output structure {{{
    pred.object   = config.gene_network.object;
    pred.ontology = config.ontology;
    pred.score    = sparse(numel(pred.object), numel(pred.ontology.term));
    pred.date     = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}

    % apply algorithm {{{
    n = numel(config.gene_network.object);
    switch config.algorithm
        case 'FF' % functional flow
            R = zeros(1, n);
            R(ismember(config.gene_network.object, config.pos_genes)) = Inf;
            s = pfp_functionalflow(config.gene_network.ADJ, R, config.FF.iter);
        case 'AF' % yet another functional flow [TBA]
            % TBA
        case 'LP' % label propagation
            Y = zeros(n, 1);
            Y(ismember(config.gene_network.object, config.pos_genes)) = 1;
            s = pfp_labelprop(config.gene_network.ADJ, Y, config.LP.thresh);
        case 'DR' % kernel diffusion ranking
        case 'RF' % Markov random field
            known = nan(1, n);
            known(ismember(config.gene_network.object, config.pos_genes)) = 1;
            known(ismember(config.gene_network.object, config.neg_genes)) = 0;
            s = pfp_mrf(config.gene_network.ADJ, known, config.RF.burnin, config.RF.budget);
        case 'RD' % random
        case 'DM' % dummy (do nothing)
        otherwise
            % nop
    end
    % }}}

    % populate pred.score {{{
    idx = pfp_ancestortermidx(config.ontology, config.term);
    pred.score(:, idx) = repmat(reshape(s, [], 1), 1, numel(idx));
    % }}}

    % save output {{{
    if ~isempty(config.output)
        fid = fopen(config.output, 'w');
        if fid == -1
            error('pfp_nbp:FileErr', 'Cannot open the output file.');
        end
        for i = 1:numel(config.gene_network.object)
            fprintf(fid, '%s\t%.2f\n', config.gene_network.object{i}, s(i));
        end
        fclose(fid);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:58:25 PM E
