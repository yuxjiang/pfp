function config = pfp_nbpconf
    %PFP_NBPCONF Network-based prediction configuration
    %
    % [config] = PFP_NBPCONF;
    %
    %   Sets up a template configuration for running network-based prediction.
    %
    % Note
    % ----
    % Some field needs to be manually modified accordingly, e.g., the initial
    % gene list ('pos_genes').
    %
    % Input
    % -----
    % None.
    %
    % Output
    % ------
    % [struct]
    % config: The PhenoPred configuration information.
    %         (required, have to be manually curated)
    %         .pos_genes    [cell]
    %         .neg_genes    [cell]
    %         .gene_network [struct] See pfp_netbuild.m
    %         .ontology     [struct] See pfp_ontbuild.m
    %                                This structure is typically not necessary
    %                                for running a NBP, however, loading an
    %                                ontology makes it easier to call evaluation
    %                                modules.
    %         .term         [char]   one term of the ontology
    %         .algorithm    [char]   algorithm code
    %                                'FF'  - functional flow
    %                                'MF'  - modified functional flow [TBA]
    %                                'LP'  - label propagation
    %                                'DR'  - kernel diffusion ranking
    %                                'RF'  - Markov random field
    %                                'RD'  - random
    %                                'DM'  - dummy (do nothing)
    %
    %         (optional, algorithm specific)
    %         .FF           [struct]  Functional flow parameters
    %           .iteration  [double]  number of iterations. default: 3
    %         .LP           [struct]  Label propagation parameters
    %           .threshold  [double]  default: 0.01
    %         .RF           [struct]  Markov random field parameters
    %           .burnin     [double]  burn-in time. default: 100
    %           .budget     [double]  time budget. default: 1000
    %
    % See Also
    % --------
    % [>] pfp_nbp.m

    % required {{{
    % INPUT
    config.pos_genes    = {};
    config.neg_genes    = {};
    config.gene_network = [];
    config.ontology     = [];
    config.term         = '';

    % OUTPUT
    config.output = '';

    % GEAR
    config.algorithm = 'FF';
    % }}}

    % optional {{{
    % default algorithm specific parameters
    config.FF.iter   = 3;    % functional flow: number of iterations
    config.LP.thresh = 0.01; % label propagation: ??
    config.RF.burnin = 100;  % Markov random field: burn-in time
    config.RF.budget = 1000; % Markov random field: maximum iteration budget
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:59:30 PM E
