// Source - https://stackoverflow.com/a
// Posted by NIMA Shahahmadian
// Retrieved 2025-11-17, License - CC BY-SA 4.0

{{flutter_js}}
{{flutter_build_config}}

const userConfig =  {"canvasKitBaseUrl": "/canvaskit/","renderer": "canvaskit","entrypointBaseUrl":"/"};

_flutter.loader.load({
  config: userConfig,
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const amaRunner = await engineInitializer.initializeEngine();
    await amaRunner.runApp();
    hideLoader();     
  }
});
