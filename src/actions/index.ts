import { defineAction } from "astro:actions";
import { z } from "astro/zod";

export const server = {
  sendEmail: defineAction({
    input: z.object({
      email: z.string().email(),
    }),
    handler: async (input) => {
      await fetch(
        `https://hfellerhoff--bf1ccd740c4211f1b3fc42dde27851f2.web.val.run?email=${input.email}`,
        {
          method: "POST",
        },
      );
    },
  }),
};
