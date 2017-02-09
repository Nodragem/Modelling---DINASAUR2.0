fixation_pole = 250;
field_size = 500;
model_space = (1:field_size) - fixation_pole;
node_to_mm = 10/field_size; % we do as if there is 5mm of SC

[phi, visual_space] = SCtoVisual(model_space*node_to_mm, 0);

figure
plot(model_space*node_to_mm, visual_space)
hold on
plot(model_space*node_to_mm, 1./visual_space)
%plot(model_space*node_to_mm, phi)


fixation_pole = 250;
field_size = 500;
model_space = (1:field_size) - fixation_pole;
node_to_deg = 180/field_size; % we do as if there is 5mm of SC

[u, v] = visualToSC(0, model_space*node_to_deg);
figure
hold on
plot(model_space*node_to_deg,  u)
plot(model_space*node_to_deg,  1./u)
hold off
