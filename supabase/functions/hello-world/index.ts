// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { multiParser, Form as _Form, FormFile } from "https://deno.land/x/multiparser@0.114.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.2.2";

serve(async (req) => {

  const supabaseClient = createClient(
    Deno.env.get("MY_SUPABASE_URL") ?? "",
    Deno.env.get("MY_SUPABASE_SERVICE_ROLE_KEY") ?? "");

  const form = await multiParser(req);

  const formFile = form?.files["image"] as FormFile;
  const uploadFileNameExtension = formFile.filename.substring(formFile.filename.lastIndexOf("."));
  const uploadFileName = `${crypto.randomUUID()}${uploadFileNameExtension}`;

  const { data, error } = await supabaseClient
    .from('incidents')
    .insert({
      description: form?.fields["description"],
      location: form?.fields["location"],
      image_path: uploadFileName
    }).select();
  
  if (data!.length > 0) { // Creation of table row was successful.
    const { data, error } =
      await supabaseClient
        .storage
        .from("incident-images")
        .upload(uploadFileName, formFile.content);
    
    if (error) {
      console.log("Upload error.");
    }
    else if (data) {
      console.log("Upload successful.");
    }
  }

  if (error) {
    return new Response("", { status: 500 });
  }
  
  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})

// To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
