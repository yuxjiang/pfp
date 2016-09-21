function [h] = pfp_preddraw(pred, obj, tau)
    %PFP_PREDDRAW Prediction draw
    %
    % [h] = PFP_PREDDRAW(pred, obj, tau);
    %
    %   Visualizes the prediction, draws the predicted sub-graph with scores
    %   greater than the given threshold.
    %
    % Input
    % -----
    % (required)
    % [struct]
    % pred: The prediction structure or annotation structure.
    %       Note that if an annotation structure (oa) is given instead of a
    %       prediction structure, We consider its field '.annotation' as
    %       '.score' and has 0/1 prediction scores. See pfp_oabuild.m.
    %
    % [char]
    % obj:  An object ID.
    %
    % (optional)
    % [double]
    % tau:  A threshold between 0 and 1.
    %       default: 0.01
    %
    % Output
    % ------
    % [figure]
    % h:    The handle of a figure object.
    %       TODO: now it returns a handle of biograph
    %
    % Dependency
    % ----------
    % [>] Bioinformatics Toolbox:biograph
    % [>] pfp_rgby.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 2 && nargin ~= 3
        error('pfp_preddraw:InputCount', 'Expected 2 or 3 inputs.');
    end

    if nargin == 2
        tau = 0.01;
    end

    % pred
    validateattributes(pred, {'struct'}, {'nonempty'}, '', 'pred', 1);

    % obj
    validateattributes(obj, {'char'}, {'nonempty'}, '', 'obj', 2);

    [found, sid] = ismember(obj, pred.object);
    if ~found
        error('pfp_preddraw:InvalidSeq', 'Invalid sequence ID.');
    end

    % tau
    validateattributes(tau, {'double'}, {'>=', 0, '<=', 1}, '', 'tau', 3);
    % }}}

    % locate terms to draw {{{
    if isfield(pred, 'score') % 'pred' is given
        score = full(pred.score(sid, :));
    elseif isfield(pred, 'annotation') % 'oa' is given
        score = full(double(pred.annotation(sid, :)));
    else
        error('pfp_preddraw:InputErr', 'The 1st input must have either ''score'' or ''annotation''.');
    end

    tid = find(score >= tau);
    % }}}

    % plot sub-ontology using biograph {{{
    n = numel(tid);

    % check if there's more than one valid term node for plotting
    if n == 0
        error('pfp_preddraw:NoTerm', 'No term has score >= %.2f.', tau);
    end

    D     = pred.ontology.DAG(tid, tid) ~= 0;
    id    = {pred.ontology.term(tid).id};
    name  = {pred.ontology.term(tid).name};
    score = score(tid);

    bg = biograph(D', id); % reverse the arrows: from root to leaf
    % Append 'UserData' for rendering a node {{{
    for i = 1 : n
        bg.Nodes(i).UserData.tid     = id{i};
        bg.Nodes(i).UserData.tname   = name{i};
        bg.Nodes(i).UserData.score   = score(i);
        bg.Nodes(i).UserData.is_leaf = ~any(D(:, i));
    end
    % }}}

    % dolayout(bg);
    set(bg, 'NodeAutoSize', 'off');
    set(bg, 'ShowTextInNode', 'none');
    set(bg.Nodes, 'shape', 'circle');
    set(bg.Nodes, 'Size', [20, 20]);

    hbg = view(bg);
    dolayout(hbg);

    lime = [.356, .647, .145]; % lime
    gray = [.345, .349, .341]; % gray
    hbg.CustomNodeDrawFcn = @(node) loc_draw_ont_node(node, lime, gray);
    % }}}

    % return handle {{{
    h = hbg;
    % h = get(hbg.biograph.hgAxis, 'Parent'); % problematic ...
    % }}}
end

% function: loc_draw_ont_node {{{
function [hg_handles] = loc_draw_ont_node(node_handle, lcolor, icolor)
    % UserData
    % .tid     [char]     GO term ID
    % .tname   [char]     GO term name
    % .score   [double]   A score between 0 and 1.
    % .is_leaf [logical]  Leaf node indicator
    %
    % Input
    % -----
    % [double]
    % lcolor: 1-by-3, leaf node color
    % icolor: 1-by-3, intermediate node color

    haxes = node_handle.up.hgAxes;
    biographScale = node_handle.up.Scale;

    % size of the node
    rx = node_handle.Size(1);
    ry = node_handle.Size(2);

    % position of the node
    x = node_handle.Position(1) * biographScale;
    y = node_handle.Position(2) * biographScale;

    hd_handles = zeros(4, 1); % two slices and two text labels.

    c = zeros(2, 3);
    if node_handle.UserData.is_leaf
        c(1, :) = lcolor;
    else
        c(1, :) = icolor;
    end
    c(2, :) = repmat(0.8, 1, 3); % light-gray

    alpha = [0, node_handle.UserData.score, 1] * 2 * pi;
    for i = 1 : 2
        t = 0.5*pi - [alpha(i):pi/50:alpha(i+1), alpha(i+1)];
        px = [x, rx / 2 * cos(t) + x, x];
        py = [y, ry / 2 * sin(t) + y, y];
        hg_handles(i) = patch(px, py, c(i, :), 'Parent', haxes);
    end

    % print term ID {{{
    hd_handles(end-1) = text(x, y+ry*0.7, node_handle.UserData.tid, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Fontsize', 9, 'Parent', haxes);
    % }}}

    % print term name {{{
    modified = regexprep(node_handle.UserData.tname, '_', ' ');
    nameseq = sprintf('\\begin{minipage}{1in}\\centering %s\\end{minipage}', modified);
    hd_handles(end) = text(x, y-ry*0.8, nameseq, ...
        'Interpreter', 'latex', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Fontsize', 10, 'Parent', haxes);
    % }}}
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:57:50 PM E
