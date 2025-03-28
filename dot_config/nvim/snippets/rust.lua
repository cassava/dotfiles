return {
  s("#derive", fmt("#[derive({}Debug, Clone)]{}", { i(1), i(0) })),
  s("#askana", fmt([[
      #[derive(Template, {}Debug, Clone)]
      #[template(ext = "html", source = r#"{}"#)]{}
  ]], { i(1), i(2), i(0) })),
}, {
}
