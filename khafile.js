let project = new Project("2dsdf_lighting");
project.addAssets("Assets/**");
project.addShaders("Shaders/**");
project.addSources("src");
await project.addProject("Libraries/dreamengine")
resolve(project);