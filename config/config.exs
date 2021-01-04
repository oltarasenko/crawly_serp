use Mix.Config
config :crawly,
       closespider_timeout: 10,
       concurrent_requests_per_domain: 8,
       middlewares: [
         Crawly.Middlewares.UniqueRequest,
         {Crawly.Middlewares.UserAgent, user_agents: ["Twitterbot"]}
       ],
       pipelines: [
         {Crawly.Pipelines.Validate, fields: [:title, :link, :description]  },
         Crawly.Pipelines.JSONEncoder,
         {Crawly.Pipelines.WriteToFile, extension: "json", folder: "/tmp"}
       ]