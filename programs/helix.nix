{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
    languages = {
      # 1. DEFINE THE LSP-AI SERVER
      language-server.lsp-ai = {
        command = "lsp-ai";
        # Increased timeout for large context processing
        timeout = 300; 
        
        config = {
          memory.file_store = {};
          
          models.deepseek_v2 = {
            type = "ollama";
            model = "deepseek-coder-v2:16b";
            max_requests_per_second = 1;
          };

          completion = {
            model = "deepseek_v2";
            parameters = { max_context = 2048; };
          };

          actions = [
            # 1. REFACTOR
            {
              action_display_name = "Refactor Code";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 4096;
                temperature = 0.1;
                top_p = 0.95;
                repeat_penalty = 1.1;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are an expert code refactoring assistant. Analyze and refactor the provided code for:
                      - Better readability and maintainability
                      - Improved performance and efficiency
                      - Modern best practices and patterns
                      - Reduced complexity

                      CRITICAL: Return ONLY the refactored code inside a markdown code block. Do not provide explanations or conversational text before/after the block.'';
                  }
                  { role = "user"; content = "File context:\n{CODE}"; }
                  { role = "user"; content = "Refactor this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 2. IMPLEMENT TODO
            {
              action_display_name = "Implement TODO";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.2;
                top_p = 0.9;
                repeat_penalty = 1.1;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are an expert coding assistant. Implement the TODO comment with clean, working, idiomatic code.
                      Return ONLY the implementation in a code block. No yapping.'';
                  }
                  { role = "user"; content = "File context:\n{CODE}"; }
                  { role = "user"; content = "Implement this TODO:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 3. ADD DOCUMENTATION
            {
              action_display_name = "Add Documentation";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 4096;
                max_tokens = 1024;
                temperature = 0.3;
                top_p = 0.9;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a documentation expert. Add comprehensive docstrings (parameters, returns, examples) and inline comments.
                      Return the code with documentation added in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Document this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 4. GENERATE TESTS
            {
              action_display_name = "Generate Tests";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 4096;
                temperature = 0.2;
                top_p = 0.95;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a QA expert. Create comprehensive unit tests (Happy path, Edge cases, Errors).
                      Return ONLY the test code in a code block. Do not explain the tests.'';
                  }
                  { role = "user"; content = "Code context:\n{CODE}"; }
                  { role = "user"; content = "Generate tests for:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 5. FIX BUGS
            {
              action_display_name = "Fix Bugs";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.1;
                top_p = 0.85;
                repeat_penalty = 1.2;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a debugging expert. Identify and fix logic errors, race conditions, or null checks.
                      Return ONLY the corrected code in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Fix bugs in:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 6. OPTIMIZE PERFORMANCE
            {
              action_display_name = "Optimize Performance";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.15;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a performance optimization expert. Optimize time complexity and memory usage.
                      Return the optimized code in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Optimize:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 7. EXPLAIN CODE
            {
              action_display_name = "Explain Code";
              model = "deepseek_v2";
              parameters = {
                keep_alive = "60m";
                max_context = 4096;
                max_tokens = 2048;
                temperature = 0.4;
                top_p = 0.9;
                messages = [
                  { role = "system"; content = "You are a code explanation expert. Provide a clear, structured explanation (Overview, Logic, Concepts, Issues)."; }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Explain this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 8. ADD ERROR HANDLING
            {
              action_display_name = "Add Error Handling";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 6144;
                max_tokens = 2048;
                temperature = 0.1;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are an error handling expert. Add Try-catch blocks, validation, and logging.
                      Return code with error handling in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Add error handling to:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 9. SIMPLIFY CODE
            {
              action_display_name = "Simplify Code";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 6144;
                max_tokens = 2048;
                temperature = 0.2;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a code simplification expert. Reduce nesting and complexity while maintaining functionality.
                      Return simplified code in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Simplify:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 10. ADD TYPE HINTS
            {
              action_display_name = "Add Type Hints";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 6144;
                max_tokens = 2048;
                temperature = 0.1;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a type annotation expert. Add comprehensive type hints and imports.
                      Return code with type hints in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Add type hints to:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 11. CONVERT LANGUAGE
            {
              action_display_name = "Convert to Another Language";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 4096;
                temperature = 0.2;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a code translation expert. Convert code to the target language using idiomatic patterns.
                      Return converted code in a code block.'';
                  }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Convert this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 12. COMPLETE AT CURSOR
            {
              action_display_name = "Complete at Cursor";
              model = "deepseek_v2";
              post_process = { extractor = "(?s)```\\w*\\n?(.*?)```"; };
              parameters = {
                keep_alive = "60m";
                max_context = 4096;
                max_tokens = 512;
                temperature = 0.2;
                messages = [
                  {
                    role = "system";
                    content = ''
                      You are a code completion expert. Complete the code at <CURSOR>.
                      Return ONLY the completion in a code block.'';
                  }
                  { role = "user"; content = "{CODE}"; }
                ];
              };
            }

            # 13. SECURITY AUDIT
            {
              action_display_name = "Security Audit";
              model = "deepseek_v2";
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.2;
                messages = [
                  { role = "system"; content = "You are a security audit expert. Analyze code for vulnerabilities (Injection, XSS, Auth, Data Exposure)."; }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Audit this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }

            # 14. CODE REVIEW
            {
              action_display_name = "Code Review";
              model = "deepseek_v2";
              parameters = {
                keep_alive = "60m";
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.3;
                messages = [
                  { role = "system"; content = "You are an expert code reviewer. Provide a structured review (Correctness, Performance, Readability, Security)."; }
                  { role = "user"; content = "Context:\n{CODE}"; }
                  { role = "user"; content = "Review this code:\n{SELECTED_TEXT}"; }
                ];
              };
            }
          ];

          chat = [
            {
              trigger = "!C";
              action_display_name = "Chat";
              model = "deepseek_v2";
              parameters = {
                max_context = 8192;
                max_tokens = 2048;
                temperature = 0.5;
                keep_alive = "60m";
                system = "You are an expert coding assistant. Provide clear, accurate, and helpful answers.";
              };
            }
          ];
        };
      };

      # 2. ATTACH THE SERVER TO YOUR LANGUAGES
      language = [
        {
          name = "rust";
          language-servers = [ "rust-analyzer" "lsp-ai" ];
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
            "\"" = "\"";
            "`" = "`";
            "<" = ">";
            "'" = "'";
          };
        }
        {
          name = "typst";
          language-servers = [ "tinymist" "lsp-ai" ];
          auto-format = true;
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
            "\"" = "\"";
            "<" = ">";
            "'" = "'";
            "*" = "*";
            "_" = "_";
            "$" = "$";
          };
        }
      ];
    };
    settings = {
      theme = "adaptive";
      editor = {
        auto-format = true;
        preview-completion-insert = false;
        completion-replace = true;
      };
      editor.statusline = {
        left = [ "mode" "spinner" "file-name" "separator" "version-control" ];
      };
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.whitespace = {
        render = {
          tab = "all";
          space = "none";
          newline = "none";
          nbsp = "none";
        };
        characters = {
          space = "·";
          nbsp = "⍽";
          tab = "→";
          newline = "⏎";
          tabpad = " ";
        };
      };
      editor.lsp = {
        display-inlay-hints = true;
      };
      editor.soft-wrap = {
        enable = true;
      };
    };
    defaultEditor = true;
  };
  home.file.".config/helix/themes/theme-light.toml".text = ''
    inherits = "onelight"
  '';
  home.file.".config/helix/themes/theme-dark.toml".text = ''
    inherits = "horizon-dark"
  '';
  home.file.".config/helix/themes/theme-blue.toml".text = ''
    inherits = "tokyonight_storm"
  '';
}
