<script setup>
import { Head } from '@inertiajs/vue3';
import TodoList from '@/Components/Home/TodoList.vue';
import BaseLayout from "@/Layouts/BaseLayout.vue";
</script>

<template>
  <BaseLayout title="Devops Todo app">
    <Head>
      <title>Todo App</title>
    </Head>
    <TodoList/>
  </BaseLayout>
</template>
