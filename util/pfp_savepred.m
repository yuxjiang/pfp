function [] = pfp_savepred(ofile, pred, tau, olist)
    %PFP_SAVEPRED Save prediction
    %
    % [] = PFP_SAVEPRED(ofile, pred, tau, olist);
    %
    %   Outputs terms that have a score above the given threshold.
    %
    % Input
    % -----
    % [char]
    % ofile:    The output filename, which has the following format:
    %           <sequence ID> <term ID>
    %
    % [struct]
    % pred:     The prediction structure.
    %
    % [double]
    % tau:      A threshold value. Specify a positive value to prevent saving
    %           zero scored predictions, e.g., 0.01.
    %
    % (optional)
    % [cell]
    % olist:    The object list.
    %           default: pred.object
    %
    % Output
    % ------
    % None.
    %
    % Dependency
    % ----------
    % [>] pfp_predproj.m
    % [>] pfp_leafterm.m

    % check inputs {{{
    if nargin < 3 || nargin > 4
        error('pfp_savepred:InputCount', 'Expected 3 or 4 inputs.');
    end

    if nargin == 3
        olist = pred.object;
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fid = fopen(ofile, 'w');
    if fid == -1
        error('pfp_savepred:FileErr', 'Cannot open the file [%s].', ofile);
    end

    % pred
    validateattributes(pred, {'struct'}, {'nonempty'}, '', 'pred', 2);

    % tau
    validateattributes(tau, {'double'}, {'real', '>=', 0, '<=', 1}, '', 'tau', 3);

    % olist
    validateattributes(olist, {'cell'}, {'nonempty'}, '', 'olist', 4);
    % }}}

    % write out the binary prediction {{{
    % For each term in the prediction structure, find the the predicted sub
    % ontology, then find the leaf terms of that sub ontology.
    pred = pfp_predproj(pred, olist, 'object');
    pred.score(pred.score < tau) = 0; % clear scores under the threshold

    for i = 1 : numel(pred.object);
        score   = full(pred.score(i, :));
        to_save = find(score >= tau);
        terms   = pred.ontology.term(score > 0);
        if ~isempty(to_save)
            % Find the leaf terms
            pred_ont.term = pred.ontology.term(to_save);
            pred_ont.DAG  = pred.ontology.DAG(to_save, to_save);
            t = pfp_leafterm(pred_ont);
            for j = 1 : numel(t)
                fprintf(fid, '%s\t%s\n', pred.object{i}, t(j).id);
            end
        end
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:38:10 PM E
