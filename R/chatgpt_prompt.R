# library(ellmer)
#
# # Create a new chat object
# chat <- chat_azure(
#   deployment_id = "gpt-4o-mini",
#   endpoint = "https://openai-doichatgpt-dev.openai.azure.com/",
#   # api_version = "2024-02-15-preview",
#   system_prompt = "You are a professional data scientist with a preference for the tidyverse.")
#
# # Interactive chat console
# live_console(chat)
# live_browser(chat)
#
# # Interactive method call
# chat$chat("What preceding languages most influenced R?")
#
# # Local image interpretation
# chat$chat(
#   "What do you see in this image?",
#   content_image_file(system.file("httr2.png", package = "ellmer"))
# )
#
# # Online image
# chat$chat(
#   "What do you see in this image?",
#   content_image_url("https://www.r-project.org/logo/Rlogo.png"))
#
# #
# chat$chat(
#   "What is the bird in this image? It is not a heron",
#   content_image_file(here::here("im_logo.png"))
# )
#
#
#
#
# # Plot interpretation
# plot(waiting ~ eruptions, data = faithful)
# chat$chat(
#   "Describe this plot in one paragraph, as suitable for inclusion in
#    alt-text. You should briefly describe the plot type, the axes, and
#    2-5 major visual patterns.",
#   content_image_plot()
# )
