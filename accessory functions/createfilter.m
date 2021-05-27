

h = zeros(9);

h = [ [0 0 0 0 1 0 0 0 0]; ...
      [0 0 0 1 1 1 0 0 0]; ...
      [0 0 1 1 1 1 1 0 0]; ...
      [0 1 1 1 1 1 1 1 0]; ...
      [1 1 1 1 1 1 1 1 1]; ...
      [0 1 1 1 1 1 1 1 0]; ...
      [0 0 1 1 1 1 1 0 0]; ...
      [0 0 0 1 1 1 0 0 0]; ...
      [0 0 0 0 1 0 0 0 0] ];

h3 = [ [0 0 0 0 0 0 0 0 0]; ...
       [0 0 0 1 1 1 0 0 0]; ...
       [0 0 1 2 2 2 1 0 0]; ...
       [0 1 2 3 4 3 2 1 0]; ...
       [0 1 2 4 5 4 2 1 0]; ...
       [0 1 2 3 4 3 2 1 0]; ...
       [0 0 1 2 2 2 1 0 0]; ...
       [0 0 0 1 1 1 0 0 0]; ...
       [0 0 0 0 0 0 0 0 0] ];

h3(find(h3 == 0)) = -5;

sm = sum(h3(:));
h3 = h3 - sm/length(h3(:));
h3 = h3/1000;


h4 = [ [0 0 0 0 5 0 0 0 0]; ...
       [0 0 0 1 1 5 0 0 0]; ...
       [0 0 1 2 2 2 5 0 0]; ...
       [0 1 2 3 4 3 2 5 0]; ...
       [0 1 2 4 5 4 2 1 0]; ...
       [0 1 2 3 4 3 2 1 0]; ...
       [0 0 1 2 2 2 1 0 0]; ...
       [0 0 0 1 1 1 0 0 0]; ...
       [0 0 0 0 1 0 0 0 0] ];