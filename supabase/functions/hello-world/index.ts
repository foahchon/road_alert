import { Application, Status } from 'https://deno.land/x/oak@v11.1.0/mod.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.2.2'

const app = new Application();

app.use(async (ctx) => {
  const body = ctx.request.body();

  if (body.type === "form-data") {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: {
            Authorization: ctx.request.headers.get('Authorization')!
          }
        }
      }
    );

    const value = body.value;
    const formData = await value.read({ maxSize: 1000000 });
    ctx.response.body = JSON.stringify(formData);
    const file = formData.files?.find(f => f.name === 'image');
    const newFileName = `${crypto.randomUUID()}${file?.originalName.substring(file?.originalName.lastIndexOf("."))}`;
    const { data: { user } } = await supabaseClient.auth.getUser();

    const insertData = {
      description: formData.fields['description'],
      address: formData.fields['address'],
      latitude: formData.fields['latitude'],
      longitude: formData.fields['longitude'],
      image_path: newFileName,
      user_id: user?.id
    };

    const { data, error } = await supabaseClient.from('incidents').insert(insertData).select();

    if (error) {
      ctx.throw(500, JSON.stringify(error));
    }

    if (data!.length > 0) {
      const { error } = await supabaseClient.storage.from('incident-images').upload(newFileName, file?.content!);

      if (error) {
        ctx.throw(500, JSON.stringify(error));
      }

      ctx.response.status = Status.OK;
      return;
    }
  }

  ctx.response.body = body.type;
});

await app.listen({ port: 8000 });
