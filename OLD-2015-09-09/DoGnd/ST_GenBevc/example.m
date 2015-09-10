% Uniformly distribute 162 particles across the surface of the unit sphere 
[V,Tri,~,Ue]=ParticleSampleSphere('N',30); % this operation takes ~8 sec on my machine (6GB RAM & 2.8 GHz processor)

% Visualize optimization progress 
figure, plot(0:numel(Ue)-1,Ue,'.-') 
set(get(gca,'Title'),'String','Optimization Progress','FontSize',20) 
xlabel('Iteration #','FontSize',15) 
ylabel('Reisz s-energy','FontSize',15)

% Visualize the mesh based on the optimal configuration of particles 
TR=TriRep(Tri,V); 
figure, h=trimesh(TR); set(h,'EdgeColor','b'), axis equal

% Subdivide the base mesh twice to obtain a spherical mesh of higher complexity 
TR_2=SubdivideSphericalMesh(TR,2); 
figure, h=trimesh(TR_2); set(h,'EdgeColor','b'), axis equal