function [offs, idx] = pfp_offspringterm(ont, list)
  %PFP_OFFSPRINGTERM Offspring term
  %
  % [offs, idx] = PFP_OFFSPRINGTERM(ont, list);
  %
  %   Returns the union of the offsprings and their indices of the given terms
  %   (self-included).
  %
  % Input
  % -----
  % [struct]
  % ont:    The ontology structure. See pfp_ontbuild.m
  %
  % [cell, char or struct]
  % list:   [cell]   - A cell of (char) term IDs.
  %         [char]   - A single (char) term ID.
  %         [struct] - An array of term structures.
  %
  % Output
  % ------
  % [struct]
  % offs:   An array of offspring term structures.
  %
  % [double]
  % idx:    An array of offspring term indices.
  %
  % Dependency
  % ----------
  % [>] pfp_getterm.m
  %
  % See Also
  % --------
  % [>] pfp_ontbuild.m

  % check inputs {{{
  if nargin ~= 2
    error('pfp_offspringterm:InputCount', 'Expected 2 inputs.');
  end

  % ont
  validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

  % list
  validateattributes(list, {'cell', 'char', 'struct'}, {'nonempty'}, '', 'list', 2);
  % }}}

  % find indices {{{
  [~, index] = pfp_getterm(ont, list);
  index(index == 0) = [];
  % }}}

  % find offsprings {{{
  walking        = false(numel(ont.term), 1);
  walking(index) = true;
  visited        = walking;
  while any(walking)
    visited = visited | walking;
    walking = full(any(ont.DAG(:, walking), 2)) & ~visited;
  end
  offs = ont.term(visited);
  idx  = reshape(find(visited), 1, []);
  % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:14:02 PM E
